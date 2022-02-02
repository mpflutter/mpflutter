package com.mpflutter.runtime.components;

import android.content.Context;
import android.util.Log;
import android.util.Size;

import com.mpflutter.runtime.MPEngine;
import com.mpflutter.runtime.components.basic.AbsorbPointer;
import com.mpflutter.runtime.components.basic.ClipOval;
import com.mpflutter.runtime.components.basic.ClipRRect;
import com.mpflutter.runtime.components.basic.ColoredBox;
import com.mpflutter.runtime.components.basic.CustomPaint;
import com.mpflutter.runtime.components.basic.CustomScrollView;
import com.mpflutter.runtime.components.basic.DecoratedBox;
import com.mpflutter.runtime.components.basic.EditableText;
import com.mpflutter.runtime.components.basic.ForegroundDecoratedBox;
import com.mpflutter.runtime.components.basic.GestureDetector;
import com.mpflutter.runtime.components.basic.GridView;
import com.mpflutter.runtime.components.basic.IgnorePointer;
import com.mpflutter.runtime.components.basic.Image;
import com.mpflutter.runtime.components.basic.ListView;
import com.mpflutter.runtime.components.basic.Offstage;
import com.mpflutter.runtime.components.basic.Opacity;
import com.mpflutter.runtime.components.basic.Overlay;
import com.mpflutter.runtime.components.basic.RichText;
import com.mpflutter.runtime.components.basic.Transform;
import com.mpflutter.runtime.components.basic.Visibility;
import com.mpflutter.runtime.components.mpkit.MPCircularProgressIndicator;
import com.mpflutter.runtime.components.mpkit.MPDatePicker;
import com.mpflutter.runtime.components.mpkit.MPIcon;
import com.mpflutter.runtime.components.mpkit.MPPageView;
import com.mpflutter.runtime.components.mpkit.MPScaffold;
import com.mpflutter.runtime.components.mpkit.MPSlider;
import com.mpflutter.runtime.components.mpkit.MPSwitch;
import com.mpflutter.runtime.components.mpkit.MPWebView;
import com.mpflutter.runtime.jsproxy.JSProxyArray;
import com.mpflutter.runtime.jsproxy.JSProxyObject;

import org.json.JSONArray;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class MPComponentFactory {

    static public final Map<String, Class<MPComponentView>> components = new HashMap() {{
        put("absorb_pointer", AbsorbPointer.class);
        put("colored_box", ColoredBox.class);
        put("clip_oval", ClipOval.class);
        put("clip_r_rect", ClipRRect.class);
        put("custom_paint", CustomPaint.class);
        put("custom_scroll_view", CustomScrollView.class);
        put("decorated_box", DecoratedBox.class);
        put("editable_text", EditableText.class);
        put("foreground_decorated_box", ForegroundDecoratedBox.class);
        put("gesture_detector", GestureDetector.class);
        put("grid_view", GridView.class);
        put("ignore_pointer", IgnorePointer.class);
        put("image", Image.class);
        put("list_view", ListView.class);
        put("offstage", Offstage.class);
        put("opacity", Opacity.class);
        put("overlay", Overlay.class);
        put("rich_text", RichText.class);
        put("transform", Transform.class);
        put("visibility", Visibility.class);
        put("mp_scaffold", MPScaffold.class);
        put("mp_date_picker", MPDatePicker.class);
        put("mp_icon", MPIcon.class);
        put("mp_page_view", MPPageView.class);
        put("mp_slider", MPSlider.class);
        put("mp_switch", MPSwitch.class);
        put("mp_web_view", MPWebView.class);
        put("mp_circular_progress_indicator", MPCircularProgressIndicator.class);
    }};

    Context context;
    MPEngine engine;
    public Map<Integer, MPComponentView> cachedView = new HashMap();
    public Map<Integer, JSProxyObject> cachedElement = new HashMap();
    List<Map> textMeasureResults = new ArrayList();
    public boolean disableCache = false;

    public MPComponentFactory(Context context, MPEngine engine) {
        this.context = context;
        this.engine = engine;
    }

    public MPComponentView create(JSProxyObject data) {
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
            JSProxyObject constraints = data.optObject("constraints");
            if (constraints != null) {
                cachedView.setConstraints(constraints);
            }
            JSProxyObject attributes = data.optObject("attributes");
            if (attributes != null) {
                cachedView.setAttributes(attributes);
            }
            JSProxyArray children = data.optArray("children");
            if (children != null) {
                cachedView.setChildren(fetchCachedChildren(children));
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
            view.attached();
            JSProxyObject constraints = data.optObject("constraints");
            if (constraints != null) {
                view.setConstraints(constraints);
            }
            JSProxyObject attributes = data.optObject("attributes");
            if (attributes != null) {
                view.setAttributes(attributes);
            }
            JSProxyArray children = data.optArray("children");
            if (children != null) {
                if (disableCache) {
                    view.setChildren(children);
                }
                else {
                    view.setChildren(fetchCachedChildren(children));
                }
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

    JSProxyArray fetchCachedChildren(JSProxyArray children) {
        JSONArray finalChildren = new JSONArray();
        for (int i = 0; i < children.length(); i++) {
            JSProxyObject obj = children.optObject(i);
            if (obj == null) continue;
            int same = obj.optInt("^", -1);
            int hashCode = obj.optInt("hashCode", -1);
            if (same >= 0 && hashCode >= 0 && cachedElement.containsKey(hashCode)) {
                finalChildren.put(cachedElement.get(hashCode));
            }
            else {
                finalChildren.put(obj);
            }
        }
        return new JSProxyArray(finalChildren);
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

    public void clear() {
        cachedView.clear();
        cachedElement.clear();
    }

}
