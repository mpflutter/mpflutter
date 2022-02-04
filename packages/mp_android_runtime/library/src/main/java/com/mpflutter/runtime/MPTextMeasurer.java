package com.mpflutter.runtime;

import android.os.Handler;
import android.util.Log;

import com.mpflutter.runtime.components.MPComponentView;
import com.mpflutter.runtime.jsproxy.JSProxyArray;
import com.mpflutter.runtime.jsproxy.JSProxyObject;

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

    public void didReceivedDoMeasureData(JSProxyObject data) {
        if (data == null) return;
        JSProxyArray items = data.optArray("items");
        if (items == null) return;
        engine.componentFactory.disableCache = true;
        List<MPComponentView> views = new ArrayList();
        Log.d("MPRuntime", "didReceivedDoMeasureData: " + items.length());
        for (int i = 0; i < items.length(); i++) {
            MPComponentView view = engine.componentFactory.create(items.optObject(i));
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
