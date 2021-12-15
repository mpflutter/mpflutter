package com.mpflutter.runtime;

import android.os.Handler;
import android.util.Log;

import com.mpflutter.runtime.components.MPComponentView;

import org.json.JSONArray;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;

public class MPTextMeasurer {

    static final String TAG = "MPTextMeasurer";

    public MPEngine engine;

    public MPTextMeasurer(MPEngine engine) {
        this.engine = engine;
    }

    public void didReceivedDoMeasureData(JSONObject data) {
        JSONArray items = data.optJSONArray("items");
        if (items == null) return;
        engine.componentFactory.disableCache = true;
        List<MPComponentView> views = new ArrayList();
        for (int i = 0; i < items.length(); i++) {
            MPComponentView view = engine.componentFactory.create(items.optJSONObject(i));
            if (view != null) {
                views.add(view);
            }
        }
        engine.componentFactory.disableCache = false;
        new Handler().postDelayed(new Runnable() {
            @Override
            public void run() {
                engine.componentFactory.flushTextMeasureResult();
            }
        }, 1);
    }

}
