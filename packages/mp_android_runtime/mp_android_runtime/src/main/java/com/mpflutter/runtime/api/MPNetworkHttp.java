package com.mpflutter.runtime.api;

import android.util.Base64;

import com.eclipsesource.v8.JavaCallback;
import com.eclipsesource.v8.V8;
import com.eclipsesource.v8.V8Array;
import com.eclipsesource.v8.V8Function;
import com.eclipsesource.v8.V8Object;
import com.mpflutter.runtime.MPEngine;
import com.mpflutter.runtime.provider.MPDataProvider;

import java.util.HashMap;
import java.util.Map;

public class MPNetworkHttp {

    static public void setupWithJSContext(MPEngine engine, V8 context) {
        V8Object wx = context.getObject("wx");
        if (wx != null) {
            wx.registerJavaMethod(new JavaCallback() {
                @Override
                public Object invoke(V8Object v8Object, V8Array v8Array) {
                    if (v8Array.length() < 1) return null;
                    V8Object options = v8Array.getObject(0);
                    if (options != null) {
                        return request(engine, options);
                    }
                    return null;
                }
            }, "request");
        }
    }

    static public V8Object request(MPEngine engine, V8Object options) {
        String url = options.getString("url");
        if (url == null) return null;
        String method = options.getString("method");
        V8Object headers = options.getObject("headers");
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
                if (success instanceof V8Function) {
                    V8Array callbackArr = new V8Array(options.getRuntime());
                    V8Object result = new V8Object(options.getRuntime());
                    result.add("data", Base64.encodeToString(this.data, Base64.NO_WRAP));
                    V8Object responseHeader = new V8Object(options.getRuntime());
                    Object[] names = this.header.keySet().toArray();
                    for (int i = 0; i < names.length; i++) {
                        responseHeader.add((String)names[i], (String)this.header.get((String)names[i]));
                    }
                    result.add("header", responseHeader);
                    result.add("statusCode", this.statusCode);
                    callbackArr.push(result);
                    ((V8Function) success).call(null, callbackArr);
                }
            }
            @Override
            public void onFail() {
                if (fail instanceof V8Function) {
                    V8Array callbackArr = new V8Array(options.getRuntime());
                    if (this.error != null) {
                        callbackArr.push(this.error);
                    }
                    else {
                        callbackArr.push("");
                    }
                    ((V8Function) fail).call(null, callbackArr);
                }
            }
        };
        dataProviderTask.start();
        V8Object mpTask = new V8Object(options.getRuntime());
        mpTask.registerJavaMethod(new JavaCallback() {
            @Override
            public Object invoke(V8Object v8Object, V8Array v8Array) {
                dataProviderTask.abort();
                return null;
            }
        }, "abort");
        return mpTask;
    }

}
