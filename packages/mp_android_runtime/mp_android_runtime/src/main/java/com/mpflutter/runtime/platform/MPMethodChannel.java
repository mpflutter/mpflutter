package com.mpflutter.runtime.platform;

import com.mpflutter.runtime.MPEngine;

import java.util.HashMap;
import java.util.UUID;

public class MPMethodChannel {

    public String channelName;
    public MPEngine engine;

    public void onMethodCall(String method, Object params, MPMethodChannelCallback result) {

    }

    public void invokeMethod(String method, Object params, MPMethodChannelCallback result) {
        if (engine != null) {
            String seqId = UUID.randomUUID().toString();
            engine.platformChannelIO.methodChannelCallbacks.put(seqId, result);
            engine.sendMessage(new HashMap(){{
                put("type", "platform_channel");
                put("message", new HashMap(){{
                    put("event", "invokeMethod");
                    put("method", channelName);
                    put("beInvokeMethod", method);
                    put("beInvokeParams", params);
                    put("seqId", seqId);
                }});
            }});
        }
    }
}
