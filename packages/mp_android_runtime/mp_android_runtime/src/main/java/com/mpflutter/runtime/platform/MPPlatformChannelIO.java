package com.mpflutter.runtime.platform;

import com.mpflutter.runtime.MPEngine;
import com.mpflutter.runtime.jsproxy.JSProxyObject;

import java.util.HashMap;
import java.util.Map;

public class MPPlatformChannelIO {

    public MPEngine engine;
    public Map<String, MPMethodChannelCallback> methodChannelCallbacks = new HashMap();
    public Map<String, MPEventChannelEventSink> eventChannelCallbacks = new HashMap();
    private Map<String, Object> pluginInstances = new HashMap();

    public MPPlatformChannelIO(MPEngine engine) {
        this.engine = engine;
        for (String channelName : MPPluginRegister.registedChannels.keySet()) {
            Class clazz = MPPluginRegister.registedChannels.get(channelName);
            try {
                Object pluginInstance = clazz.newInstance();
                if (pluginInstance instanceof MPMethodChannel) {
                    ((MPMethodChannel) pluginInstance).channelName = channelName;
                    ((MPMethodChannel) pluginInstance).engine = engine;
                }
                else if (pluginInstance instanceof MPEventChannel) {
                    ((MPEventChannel) pluginInstance).channelName = channelName;
                    ((MPEventChannel) pluginInstance).engine = engine;
                }
                pluginInstances.put(channelName, pluginInstance);
            } catch (Throwable e) {
                e.printStackTrace();
            }
        }
    }

    public void didReceivedMessage(JSProxyObject data) {
        String event = data.optString("event", null);
        if (event == null) return;
        if (event.contentEquals("invokeMethod")) {
            String method = data.optString("method", null);
            String beInvokeMethod = data.optString("beInvokeMethod", null);
            if (method == null || beInvokeMethod == null) {
                return;
            }
            Object beInvokeParams = data.opt("beInvokeParams");
            Object seqId = data.opt("seqId");
            Object instance = pluginInstances.get(method);
            if (instance instanceof MPMethodChannel) {
                ((MPMethodChannel) instance).onMethodCall(beInvokeMethod, beInvokeParams, new MPMethodChannelCallback(){
                    @Override
                    public void success(Object result) {
                        engine.sendMessage(new HashMap(){{
                            put("type", "platform_channel");
                            put("message", new HashMap(){{
                                put("event", "callbackResult");
                                put("result", result);
                                put("seqId", seqId);
                            }});
                        }});
                    }

                    @Override
                    public void fail(String error) {
                        engine.sendMessage(new HashMap(){{
                            put("type", "platform_channel");
                            put("message", new HashMap(){{
                                put("event", "callbackResult");
                                put("result", "ERROR: " + error);
                                put("seqId", seqId);
                            }});
                        }});
                    }
                });
            }
            else if (instance instanceof MPEventChannel) {
                if (beInvokeMethod.contentEquals("listen")) {
                    ((MPEventChannel) instance).onListen(beInvokeParams, new MPEventChannelEventSink() {
                        @Override
                        public void onData(Object data) {
                            engine.sendMessage(new HashMap(){{
                                put("type", "platform_channel");
                                put("message", new HashMap(){{
                                    put("event", "callbackEventSink");
                                    put("method", method);
                                    put("result", data);
                                    put("seqId", seqId);
                                }});
                            }});
                        }
                    });
                }
                else if (beInvokeMethod.contentEquals("cancel")) {
                    ((MPEventChannel) instance).onCancel(beInvokeParams);
                }
            }
        }
        else if (event.contentEquals("callbackResult")) {
            String seqId = data.optString("seqId", null);
            if (seqId == null) return;
            Object result = data.opt("result");
            MPMethodChannelCallback methodChannelCallback = methodChannelCallbacks.get(seqId);
            if (methodChannelCallback != null) {
                if (result instanceof String && ((String) result).startsWith("ERROR:")) {
                    methodChannelCallback.fail((String) result);
                }
                else {
                    methodChannelCallback.success(result);
                }
                methodChannelCallbacks.remove(seqId);
            }
        }
    }

}
