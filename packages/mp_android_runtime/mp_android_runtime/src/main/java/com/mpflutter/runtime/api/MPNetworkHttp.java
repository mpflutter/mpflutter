package com.mpflutter.runtime.api;

import android.util.Base64;

import com.quickjs.JSArray;
import com.quickjs.JSContext;
import com.quickjs.JSFunction;
import com.quickjs.JSObject;
import com.quickjs.JavaCallback;

import org.jetbrains.annotations.NotNull;

import java.io.IOException;

import okhttp3.Call;
import okhttp3.Callback;
import okhttp3.MediaType;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.RequestBody;
import okhttp3.Response;

public class MPNetworkHttp {

    static private OkHttpClient httpClient = new OkHttpClient();

    static public void setupWithJSContext(JSContext context, JSObject selfObject) {
        JSObject wx = context.getObject("wx");
        if (wx != null) {
            wx.set("request", new JSFunction(context, new JavaCallback() {
                @Override
                public Object invoke(JSObject receiver, JSArray args) {
                    if (args.length() < 1) return null;
                    JSObject options = args.getObject(0);
                    if (options != null) {
                        return request(options);
                    }
                    return null;
                }
            }));
        }
    }

    static public JSObject request(JSObject options) {
        String url = options.getString("url");
        if (url == null) return null;
        String method = options.getString("method");
        JSObject headers = options.getObject("headers");
        boolean hasHeaders = headers != null && !headers.isUndefined();
        String contentType = hasHeaders ? headers.getString("content-type") : "application/oc-stream";
        String data = options.getString("data");
        Object success = options.get("success");
        Object fail = options.get("fail");
        Request.Builder httpRequestBuilder = new Request.Builder();
        httpRequestBuilder.url(url);
        if (hasHeaders) {
            String[] keys = headers.getKeys();
            for (int i = 0; i < keys.length; i++) {
                String value = headers.getString(keys[i]);
                if (value != null) {
                    httpRequestBuilder.addHeader(keys[i], value);
                }
            }
        }
        if (method.contentEquals("GET")) {
            httpRequestBuilder.method("GET", null);
        }
        else {
            httpRequestBuilder.method(method != null ? method : "GET", data == null ? null : RequestBody.create(data, MediaType.get(contentType)));
        }
        Request httpRequest = httpRequestBuilder.build();
        Call httpCall = httpClient.newCall(httpRequest);
        httpCall.enqueue(new Callback() {
            @Override
            public void onFailure(@NotNull Call call, @NotNull IOException e) {
                if (fail instanceof JSFunction) {
                    JSArray callbackArr = new JSArray(options.getContext());
                    callbackArr.push(e.toString());
                    ((JSFunction) fail).call(null, callbackArr);
                }
            }

            @Override
            public void onResponse(@NotNull Call call, @NotNull Response response) throws IOException {
                try {
                    byte[] responseData = response.body().bytes();
                    if (success instanceof JSFunction) {
                        JSArray callbackArr = new JSArray(options.getContext());
                        JSObject result = new JSObject(options.getContext());
                        result.set("data", Base64.encodeToString(responseData, Base64.NO_WRAP));
                        JSObject responseHeader = new JSObject(options.getContext());
                        Object[] names = response.headers().names().toArray();
                        for (int i = 0; i < names.length; i++) {
                            responseHeader.set((String)names[i], response.header((String)names[i]));
                        }
                        result.set("header", responseHeader);
                        result.set("statusCode", response.code());
                        callbackArr.push(result);
                        ((JSFunction) success).call(null, callbackArr);
                    }
                } catch (Throwable e) {
                    e.printStackTrace();
                }
            }
        });
        JSObject mpTask = new JSObject(options.getContext());
        mpTask.set("abort", new JSFunction(options.getContext(), new JavaCallback() {
            @Override
            public Object invoke(JSObject receiver, JSArray args) {
                if (!httpCall.isCanceled() && !httpCall.isExecuted()) {
                    httpCall.cancel();
                }
                return null;
            }
        }));
        return mpTask;
    }

}
