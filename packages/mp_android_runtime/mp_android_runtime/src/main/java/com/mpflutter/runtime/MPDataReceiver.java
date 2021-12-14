package com.mpflutter.runtime;

import org.json.JSONException;
import org.json.JSONObject;

public interface MPDataReceiver {
    void didReceivedFrameData(JSONObject frameData) throws JSONException;
}
