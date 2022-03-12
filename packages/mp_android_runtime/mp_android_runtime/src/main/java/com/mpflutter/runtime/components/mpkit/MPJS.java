package com.mpflutter.runtime.components.mpkit;

import com.eclipsesource.v8.JavaCallback;
import com.eclipsesource.v8.V8Array;
import com.eclipsesource.v8.V8Function;
import com.eclipsesource.v8.V8Object;
import com.mpflutter.runtime.MPEngine;
import com.mpflutter.runtime.jsproxy.JSProxyObject;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;
import java.io.InputStream;
import java.util.HashMap;

public class MPJS {

    MPEngine engine;

    public MPJS(MPEngine engine) {
        this.engine = engine;
        inject();
    }

    void inject() {
        try {
            InputStream inputStream = engine.context.getAssets().open("mp_android_mpjs.js");
            byte[] data = new byte[inputStream.available()];
            inputStream.read(data);
            inputStream.close();
            String script = new String(data);
            engine.jsContext.executeScript(script, "");
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public void didReceivedMessage(JSProxyObject message) {
        if (message == null) return;
        V8Object value = engine.jsContext.getObject("MPJS").getObject("instance").getObject("handleMessage");
        Object requestId = message.opt("requestId");
        if (value != null && value instanceof V8Function) {
            V8Array callbackArr = new V8Array(value.getRuntime());
            if (message.jsonObject != null) {
                V8Object v8JSON = (V8Object) value.getRuntime().get("JSON");
                V8Array v8Array = new V8Array(value.getRuntime());
                v8Array.push(message.jsonObject.toString());
                callbackArr.push(v8JSON.executeObjectFunction("parse", v8Array));
            }
            else if (message.qV8Object != null) {
                callbackArr.push(message.qV8Object);
            }
            callbackArr.push(new V8Function(value.getRuntime(), new JavaCallback() {
                @Override
                public Object invoke(V8Object receiver, V8Array args) {
                    if (args.length() <= 0) return null;
                    String result = args.getString(0);
                    JSONObject map = null;
                    try {
                        map = new JSONObject(result);
                    } catch (JSONException e) {
                        e.printStackTrace();
                        return null;
                    }
                    JSONObject finalMap = map;
                    engine.sendMessage(new HashMap(){{
                        put("type", "mpjs");
                        put("message", new HashMap(){{
                            put("requestId", requestId);
                            put("result", finalMap != null ? finalMap.opt("value") : null);
                        }});
                    }});
                    return null;
                }
            }));
            callbackArr.push(new V8Function(value.getRuntime(), new JavaCallback() {
                @Override
                public Object invoke(V8Object receiver, V8Array args) {
                    if (args.length() <= 0) return null;
                    String result = args.getString(0);
                    JSONObject map = null;
                    try {
                        map = new JSONObject(result);
                    } catch (JSONException e) {
                        e.printStackTrace();
                        return null;
                    }
                    JSONObject finalMap = map;
                    engine.sendMessage(new HashMap(){{
                        put("type", "mpjs");
                        put("message", finalMap);
                    }});
                    return null;
                }
            }));
            ((V8Function) value).call(null, callbackArr);
        }
    }

}
