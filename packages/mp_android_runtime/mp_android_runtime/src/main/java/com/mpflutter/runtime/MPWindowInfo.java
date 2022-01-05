package com.mpflutter.runtime;

import android.app.Activity;
import android.content.Context;
import android.util.DisplayMetrics;

import com.mpflutter.runtime.components.MPUtils;

import java.util.HashMap;

public class MPWindowInfo {

    public MPEngine engine;

    public MPWindowInfo(MPEngine engine) {
        this.engine = engine;
    }

    void updateWindowInfo() {
        Context context = engine.context;
        if (context instanceof Activity) {
            DisplayMetrics displayMetrics = new DisplayMetrics();
            ((Activity) context).getWindowManager().getDefaultDisplay().getMetrics(displayMetrics);
            engine.sendMessage(new HashMap(){{
                put("type", "window_info");
                put("message", new HashMap(){{
                    put("window", new HashMap(){{
                        put("width", MPUtils.px2dp(displayMetrics.widthPixels, context));
                        put("height", MPUtils.px2dp(displayMetrics.heightPixels, context));
                        put("padding", new HashMap(){{
                            put("top", 0);
                            put("bottom", 0);
                        }});
                    }});
                    put("devicePixelRatio", MPUtils.scale(context));
                }});
            }});
        }
    }

}
