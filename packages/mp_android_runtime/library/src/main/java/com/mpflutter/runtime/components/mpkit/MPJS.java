package com.mpflutter.runtime.components.mpkit;

import com.mpflutter.runtime.MPEngine;
import com.mpflutter.runtime.jsproxy.JSProxyObject;
import com.quickjs.JSArray;
import com.quickjs.JSFunction;
import com.quickjs.JSObject;
import com.quickjs.JavaCallback;

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
        JSObject value = engine.jsContext.getObject("MPJS").getObject("instance").getObject("handleMessage");
        Object requestId = message.opt("requestId");
        if (value != null && value instanceof JSFunction) {
            JSArray callbackArr = new JSArray(value.getContext());
            if (message.jsonObject != null) {
                callbackArr.push(new JSObject(value.getContext(), message.jsonObject));
            }
            else if (message.qjsObject != null) {
                callbackArr.push(message.qjsObject);
            }
            callbackArr.push(new JSFunction(value.getContext(), new JavaCallback() {
                @Override
                public Object invoke(JSObject receiver, JSArray args) {
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
            callbackArr.push(new JSFunction(value.getContext(), new JavaCallback() {
                @Override
                public Object invoke(JSObject receiver, JSArray args) {
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
            ((JSFunction) value).call(null, callbackArr);
        }
    }

}
