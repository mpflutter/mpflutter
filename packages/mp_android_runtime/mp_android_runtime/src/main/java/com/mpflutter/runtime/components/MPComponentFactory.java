package com.mpflutter.runtime.components;

import android.content.Context;
import android.util.Log;
import android.util.Size;

import com.mpflutter.runtime.MPEngine;
import com.mpflutter.runtime.components.basic.AbsorbPointer;
import com.mpflutter.runtime.components.basic.ClipOval;
import com.mpflutter.runtime.components.basic.ClipRRect;
import com.mpflutter.runtime.components.basic.ColoredBox;
import com.mpflutter.runtime.components.basic.DecoratedBox;
import com.mpflutter.runtime.components.basic.ForegroundDecoratedBox;
import com.mpflutter.runtime.components.basic.GestureDetector;
import com.mpflutter.runtime.components.basic.IgnorePointer;
import com.mpflutter.runtime.components.basic.Image;
import com.mpflutter.runtime.components.basic.Offstage;
import com.mpflutter.runtime.components.basic.Opacity;
import com.mpflutter.runtime.components.basic.RichText;
import com.mpflutter.runtime.components.basic.Transform;
import com.mpflutter.runtime.components.basic.Visibility;
import com.mpflutter.runtime.components.mpkit.MPScaffold;

import org.json.JSONArray;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class MPComponentFactory {

    static Map<String, Class<MPComponentView>> components = new HashMap() {{
        put("absorb_pointer", AbsorbPointer.class);
        put("colored_box", ColoredBox.class);
        put("clip_oval", ClipOval.class);
        put("clip_r_rect", ClipRRect.class);
        put("decorated_box", DecoratedBox.class);
        put("foreground_decorated_box", ForegroundDecoratedBox.class);
        put("gesture_detector", GestureDetector.class);
        put("ignore_pointer", IgnorePointer.class);
        put("image", Image.class);
        put("offstage", Offstage.class);
        put("opacity", Opacity.class);
        put("rich_text", RichText.class);
        put("transform", Transform.class);
        put("visibility", Visibility.class);
        put("mp_scaffold", MPScaffold.class);
    }};

    Context context;
    MPEngine engine;
    Map<Integer, MPComponentView> cachedView = new HashMap();
    Map<Integer, JSONObject> cachedElement = new HashMap();
    List<Map> textMeasureResults = new ArrayList();
    public boolean disableCache = false;

    public MPComponentFactory(Context context, MPEngine engine) {
        this.context = context;
        this.engine = engine;
    }

    public MPComponentView create(JSONObject data) {
        if (data == null) return null;
        int same = data.optInt("^", -1);
        String name = data.optString("name", null);
        int hashCode = data.optInt("hashCode", -1);
        if (same == 1 && hashCode >= 0) {
            MPComponentView cachedView = this.cachedView.get(hashCode);
            return cachedView;
        }
        if (name == null || hashCode < 0) {
            return null;
        }
        cachedElement.put(hashCode, data);
        MPComponentView cachedView = !disableCache ? this.cachedView.get(hashCode) : null;
        if (cachedView != null) {
            JSONObject constraints = data.optJSONObject("constraints");
            if (constraints != null) {
                cachedView.setConstraints(constraints);
            }
            JSONObject attributes = data.optJSONObject("attributes");
            if (attributes != null) {
                cachedView.setAttributes(attributes);
            }
            JSONArray children = data.optJSONArray("children");
            if (children != null) {
                cachedView.setChildren(children);
            }
            return cachedView;
        }
        Class<MPComponentView> clazz = components.get(name);
        if (clazz == null) {
            clazz = MPComponentView.class;
        }
        try {
            MPComponentView view = clazz.getConstructor(Context.class).newInstance(context);
            view.factory = this;
            view.engine = engine;
            view.hashCode = hashCode;
            JSONObject constraints = data.optJSONObject("constraints");
            if (constraints != null) {
                view.setConstraints(constraints);
            }
            JSONObject attributes = data.optJSONObject("attributes");
            if (attributes != null) {
                view.setAttributes(attributes);
            }
            JSONArray children = data.optJSONArray("children");
            if (children != null) {
                view.setChildren(children);
            }
            if (!disableCache) {
                this.cachedView.put(hashCode, view);
            }
            return view;
        } catch (Throwable e) {
            e.printStackTrace();
            return null;
        }
    }

    public void callbackTextMeasureResult(int measureId, Size size) {
        textMeasureResults.add(new HashMap(){{
            put("measureId", measureId);
            put("size", new HashMap(){{
                put("width", size.getWidth());
                put("height", size.getHeight());
            }});
        }});
    }

    public void flushTextMeasureResult() {
        if (!textMeasureResults.isEmpty()) {
            engine.sendMessage(new HashMap(){{
                put("type", "rich_text");
                put("message", new HashMap(){{
                    put("event", "onMeasured");
                    put("data", textMeasureResults);
                }});
            }});
            textMeasureResults = new ArrayList();
        }
    }

}
