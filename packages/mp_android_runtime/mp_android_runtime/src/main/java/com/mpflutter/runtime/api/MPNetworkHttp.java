package com.mpflutter.runtime.api;

import android.util.Base64;

import com.mpflutter.runtime.MPEngine;
import com.mpflutter.runtime.provider.MPDataProvider;
import com.quickjs.JSArray;
import com.quickjs.JSContext;
import com.quickjs.JSFunction;
import com.quickjs.JSObject;
import com.quickjs.JavaCallback;

import org.jetbrains.annotations.NotNull;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

import okhttp3.Call;
import okhttp3.Callback;
import okhttp3.MediaType;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.RequestBody;
import okhttp3.Response;

public class MPNetworkHttp {

    static public void setupWithJSContext(MPEngine engine, JSContext context, JSObject selfObject) {
        JSObject wx = context.getObject("wx");
        if (wx != null) {
            wx.set("request", new JSFunction(context, new JavaCallback() {
                @Override
                public Object invoke(JSObject receiver, JSArray args) {
                    if (args.length() < 1) return null;
                    JSObject options = args.getObject(0);
                    if (options != null) {
                        return request(engine, options);
                    }
                    return null;
                }
            }));
        }
    }

    static public JSObject request(MPEngine engine, JSObject options) {
        String url = options.getString("url");
        if (url == null) return null;
        String method = options.getString("method");
        JSObject headers = options.getObject("headers");
        boolean hasHeaders = headers != null && !headers.isUndefined();
        String contentType = hasHeaders ? headers.getString("content-type") : "application/oc-stream";
        String data = options.getString("data");
        Object success = options.get("success");
        Object fail = options.get("fail");

        MPDataProvider.HttpRequestTask dataProviderTask = engine.provider.dataProvider.createHttpRequest();
        dataProviderTask.request = new MPDataProvider.HttpRequest();
        dataProviderTask.request.url = url;
        dataProviderTask.request.method = method;
        if (hasHeaders) {
            Map taskHeader = new HashMap();
            String[] keys = headers.getKeys();
            for (int i = 0; i < keys.length; i++) {
                String value = headers.getString(keys[i]);
                if (value != null) {
                    taskHeader.put(keys[i], value);
                }
            }
            dataProviderTask.request.header = taskHeader;
        }
        dataProviderTask.request.contentType = contentType;
        dataProviderTask.request.data = data;
        dataProviderTask.response = new MPDataProvider.HttpResponse() {
            @Override
            public void onSuccess() {
                if (success instanceof JSFunction) {
                    JSArray callbackArr = new JSArray(options.getContext());
                    JSObject result = new JSObject(options.getContext());
                    result.set("data", Base64.encodeToString(this.data, Base64.NO_WRAP));
                    JSObject responseHeader = new JSObject(options.getContext());
                    Object[] names = this.header.keySet().toArray();
                    for (int i = 0; i < names.length; i++) {
                        responseHeader.set((String)names[i], (String)this.header.get((String)names[i]));
                    }
                    result.set("header", responseHeader);
                    result.set("statusCode", this.statusCode);
                    callbackArr.push(result);
                    ((JSFunction) success).call(null, callbackArr);
                }
            }
            @Override
            public void onFail() {
                if (fail instanceof JSFunction) {
                    JSArray callbackArr = new JSArray(options.getContext());
                    if (this.error != null) {
                        callbackArr.push(this.error);
                    }
                    else {
                        callbackArr.push("");
                    }
                    ((JSFunction) fail).call(null, callbackArr);
                }
            }
        };
        dataProviderTask.start();
        JSObject mpTask = new JSObject(options.getContext());
        mpTask.set("abort", new JSFunction(options.getContext(), new JavaCallback() {
            @Override
            public Object invoke(JSObject receiver, JSArray args) {
                dataProviderTask.abort();
                return null;
            }
        }));
        return mpTask;
    }

}
