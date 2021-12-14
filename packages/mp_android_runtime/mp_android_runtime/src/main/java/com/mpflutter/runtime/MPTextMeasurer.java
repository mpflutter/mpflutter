package com.mpflutter.runtime;

import android.util.Log;

import org.json.JSONObject;

public class MPTextMeasurer {

    static final String TAG = "MPTextMeasurer";

    public MPEngine engine;

    public MPTextMeasurer(MPEngine engine) {
        this.engine = engine;
    }

    public void didReceivedDoMeasureData(JSONObject data) {
        Log.d(TAG, "didReceivedDoMeasureData: ");
    }

}
