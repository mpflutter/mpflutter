package com.mpflutter.runtime.platform;

import com.mpflutter.runtime.MPEngine;

public class MPEventChannel {

    String channelName;
    MPEngine engine;

    public void onListen(Object params, MPEventChannelEventSink eventSink) {}
    public void onCancel(Object params) {}

}
