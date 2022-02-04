package com.mpflutter.runtime.components.mpkit;

import android.content.Context;
import android.view.View;

import androidx.annotation.NonNull;

import com.mpflutter.runtime.MPEngine;
import com.mpflutter.runtime.components.MPComponentView;
import com.mpflutter.runtime.components.MPUtils;
import com.mpflutter.runtime.jsproxy.JSProxyArray;
import com.mpflutter.runtime.jsproxy.JSProxyObject;

import org.json.JSONArray;
import org.json.JSONObject;

import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

public class MPPlatformView extends MPComponentView {

    static Map<String, MPPlatformViewCallback> invokeMethodCallback = new HashMap();

    static public void didReceivedPlatformViewMessage(JSProxyObject message, MPEngine engine) {
        String event = message.optString("event", null);
        if (event != null && event.contentEquals("methodCall") && message.optInt("hashCode", 0) != 0) {
            int hashCode = message.optInt("hashCode", 0);
            MPComponentView target = engine.componentFactory.cachedView.get(hashCode);
            if (target instanceof MPPlatformView) {
                boolean requireResult = message.optBoolean("requireResult", false);
                String seqId = message.optString("seqId", null);
                ((MPPlatformView) target).onMethodCall(message.optString("method", ""), message.opt("params"), new MPPlatformViewCallback() {
                    @Override
                    public void success(Object result) {
                        if (requireResult && !MPUtils.isNull(seqId)) {
                            engine.sendMessage(new HashMap(){{
                                put("type", "platform_view");
                                put("message", new HashMap(){{
                                    put("event", "methodCallCallback");
                                    put("seqId", seqId);
                                    put("result", result);
                                }});
                            }});
                        }
                    }
                });
            }
        }
        else if (!MPUtils.isNull(event) && event.contentEquals("methodCallCallback")) {
            String seqId = message.optString("seqId", null);
            if (!MPUtils.isNull(seqId) && invokeMethodCallback.containsKey(seqId)) {
                invokeMethodCallback.get(seqId).success(message.opt("result"));
                invokeMethodCallback.remove(seqId);
            }
        }
    }

    public MPPlatformView(@NonNull Context context) {
        super(context);
    }

    public void onMethodCall(String method, Object params, MPPlatformViewCallback callback) { }

    public void invokeMethod(String method, Object params) {
        if (method == null) return;
        String seqId = UUID.randomUUID().toString();
        engine.sendMessage(new HashMap(){{
            put("type", "platform_view");
            put("message", new HashMap(){{
                put("event", "methodCall");
                put("hashCode", hashCode);
                put("method", method);
                put("params", params);
                put("seqId", seqId);
            }});
        }});
    }

    public void invokeMethod(String method, Object params, MPPlatformViewCallback resultCallback) {
        if (resultCallback == null) {
            invokeMethod(method, params);
            return;
        }
        if (method == null) return;
        String seqId = UUID.randomUUID().toString();
        invokeMethodCallback.put(seqId, resultCallback);
        engine.sendMessage(new HashMap(){{
            put("type", "platform_view");
            put("message", new HashMap(){{
                put("event", "methodCall");
                put("hashCode", hashCode);
                put("method", method);
                put("params", params);
                put("seqId", seqId);
                put("requireResult", true);
            }});
        }});
    }
}
