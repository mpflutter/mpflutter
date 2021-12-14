package com.mpflutter.runtime;

import android.util.Size;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

public class MPRouter {

    public MPEngine engine;
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

    void didReceivedRouteData(JSONObject message) throws JSONException {
        String event = message.getString("event");
        if (event.contentEquals("responseRoute")) {
            responseRoute(message);
        }
    }

    void dispose(int viewId) {

    }

    void triggerPop(int viewId) {

    }

    private void responseRoute(JSONObject message) {
        try {
            String requestId = message.getString("requestId");
            int routeId = message.getInt("routeId");
            if (routeResponseHandler.containsKey(requestId)) {
                routeResponseHandler.get(requestId).onResponse(routeId);
                routeResponseHandler.remove(requestId);
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

}
