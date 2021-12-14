package com.mpflutter.runtime.components;

import android.content.Context;

import com.mpflutter.runtime.MPEngine;
import com.mpflutter.runtime.components.basic.ColoredBox;
import com.mpflutter.runtime.components.mpkit.MPScaffold;

import org.json.JSONArray;
import org.json.JSONObject;

import java.lang.reflect.InvocationTargetException;
import java.util.HashMap;
import java.util.Map;

public class MPComponentFactory {

    static Map<String, Class<MPComponentView>> components = new HashMap() {{
        put("colored_box", ColoredBox.class);
        put("mp_scaffold", MPScaffold.class);
    }};

    Context context;
    MPEngine engine;
    Map<Integer, MPComponentView> cachedView = new HashMap();
    Map<Integer, JSONObject> cachedElement = new HashMap();
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

}
