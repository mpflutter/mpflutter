package com.mpflutter.runtime;

import android.app.Activity;
import android.content.Intent;
import android.util.Size;

import com.mpflutter.runtime.jsproxy.JSProxyObject;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

public class MPRouter {

    public MPEngine engine;
    public Activity activeActivity;
    private Map<String, MPRouteResponse> routeResponseHandler = new HashMap();
    private boolean doBacking = false;
    private Integer thePushingRouteId;

    public MPRouter(MPEngine engine) {
        this.engine = engine;
    }

    void requestRoute(String routeName, Map routeParams, boolean isRoot, Size viewport, MPRouteResponse responseCallback) {
        if (thePushingRouteId != null) {
            int value = thePushingRouteId;
            thePushingRouteId = null;
            engine.sendMessage(new HashMap(){{
                put("type", "router");
                put("message", new HashMap(){{
                    put("event", "updateRoute");
                    put("routeId", value);
                    put("viewport", new HashMap(){{
                        put("width", viewport.getWidth());
                        put("height", viewport.getHeight());
                    }});
                }});
            }});
            responseCallback.onResponse(value);
            return;
        }
        String requestId = UUID.randomUUID().toString();
        routeResponseHandler.put(requestId, responseCallback);
        engine.sendMessage(new HashMap(){{
            put("type", "router");
            put("message", new HashMap(){{
                put("event", "requestRoute");
                put("requestId", requestId);
                put("name", routeName != null ? routeName : "/");
                put("params", routeParams != null ? routeParams : new HashMap());
                put("viewport", new HashMap(){{
                    put("width", viewport.getWidth());
                    put("height", viewport.getHeight());
                }});
                put("root", isRoot);
            }});
        }});
    }

    void updateRouteViewport(int routeId, Size viewport) {
        engine.sendMessage(new HashMap(){{
            put("type", "router");
            put("message", new HashMap(){{
                put("event", "updateRoute");
                put("routeId", routeId);
                put("viewport", new HashMap(){{
                    put("width", viewport.getWidth());
                    put("height", viewport.getHeight());
                }});
            }});
        }});
    }

    void didReceivedRouteData(JSProxyObject message) {
        String event = message.optString("event", null);
        if (event == null) return;
        if (event.contentEquals("responseRoute")) {
            responseRoute(message);
        }
        else if (event.contentEquals("didPush")) {
            didPush(message);
        }
        else if (event.contentEquals("didReplace")) {
            didReplace(message);
        }
        else if (event.contentEquals("didPop")) {
            didPop();
        }
    }

    void didPush(JSProxyObject message) {
        int routeId = message.optInt("routeId", -1);
        if (routeId < 0) return;
        thePushingRouteId = routeId;
        Intent intent = new Intent(engine.context, MPActivity.class);
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        intent.putExtra("engineId", engine.hashCode());
        intent.putExtra("routeId", routeId);
        engine.context.startActivity(intent);
    }

    void didReplace(JSProxyObject message) {
        int routeId = message.optInt("routeId", -1);
        if (routeId < 0) return;
        thePushingRouteId = routeId;
        if (activeActivity != null) {
            activeActivity.finish();
        }
        Intent intent = new Intent(engine.context, MPActivity.class);
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        intent.putExtra("engineId", engine.hashCode());
        intent.putExtra("routeId", routeId);
        engine.context.startActivity(intent);
    }

    void didPop() {
        doBacking = true;
        if (activeActivity != null) {
            activeActivity.finish();
        }
        doBacking = false;
    }

    void dispose(int viewId) {
        if (doBacking) {
            return;
        }
        engine.sendMessage(new HashMap(){{
            put("type", "router");
            put("message", new HashMap(){{
                put("event", "disposeRoute");
                put("routeId", viewId);
            }});
        }});
    }

    void triggerPop(int viewId) {
        if (doBacking) {
            return;
        }
        engine.sendMessage(new HashMap(){{
            put("type", "router");
            put("message", new HashMap(){{
                put("event", "popToRoute");
                put("routeId", viewId);
            }});
        }});
    }

    private void responseRoute(JSProxyObject message) {
        String requestId = message.optString("requestId", "");
        int routeId = message.optInt("routeId");
        if (routeResponseHandler.containsKey(requestId)) {
            routeResponseHandler.get(requestId).onResponse(routeId);
            routeResponseHandler.remove(requestId);
        }
    }

}
