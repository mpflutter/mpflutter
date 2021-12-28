package com.mpflutter.runtime;

import com.mpflutter.runtime.jsproxy.JSProxyObject;

import org.json.JSONException;
import org.json.JSONObject;

public interface MPDataReceiver {
    void didReceivedFrameData(JSProxyObject frameData);
}
