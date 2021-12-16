package com.mpflutter.runtime.components;

import android.content.Context;
import android.view.ViewGroup;
import android.widget.FrameLayout;

import androidx.annotation.NonNull;

import com.mpflutter.runtime.MPEngine;
import com.mpflutter.runtime.components.basic.DecoratedBox;
import com.mpflutter.runtime.components.basic.GestureDetector;
import com.mpflutter.runtime.components.basic.Offstage;
import com.mpflutter.runtime.components.basic.Visibility;

import org.json.JSONArray;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;

public class MPComponentView extends FrameLayout {

    public MPComponentFactory factory;
    public MPEngine engine;
    public int hashCode;
    public JSONObject constraints;
    public JSONObject attributes;
    protected JSONObject adjustConstraints;

    public MPComponentView(@NonNull Context context) {
        super(context);
        setClipChildren(false);
    }

    public void setConstraints(JSONObject constraints) {
        this.constraints = constraints;
        updateLayout();
    }

    public void setAdjustConstraints(JSONObject adjustConstraints) {
        this.adjustConstraints = adjustConstraints;
        updateLayout();
    }

    public void updateLayout() {
        if (constraints == null) return;
        double x = constraints.optDouble("x");
        double y = constraints.optDouble("y");
        double w = constraints.optDouble("w");
        double h = constraints.optDouble("h");
        if (this.adjustConstraints != null && (this.getParent() instanceof GestureDetector || this.getParent() instanceof Visibility || this.getParent() instanceof DecoratedBox)) {
            x -= this.adjustConstraints.optDouble("x", 0.0);
            y -= this.adjustConstraints.optDouble("y", 0.0);
        }
        setX(MPUtils.dp2px(x, getContext()));
        setY((MPUtils.dp2px(y, getContext())));
        setMinimumWidth(MPUtils.dp2px(w, getContext()));
        setMinimumHeight(MPUtils.dp2px(h, getContext()));
    }

    public void setAttributes(JSONObject attributes) {
        this.attributes = attributes;
    }

    public void setChildren(JSONArray children) {
        if (children == null) return;
        List<MPComponentView> makeSubviews = new ArrayList();
        for (int i = 0; i < children.length(); i++) {
            MPComponentView view = factory.create(children.optJSONObject(i));
            if (view != null) {
                makeSubviews.add(view);
            }
        }
        boolean changed = false;
        if (makeSubviews.size() != getChildCount()) {
            changed = true;
        } else {
            for (int i = 0; i < makeSubviews.size(); i++) {
                if (makeSubviews.get(i) != getChildAt(i)) {
                    changed = true;
                    break;
                }
            }
        }
        if (changed) {
            removeAllViews();
            for (int i = 0; i < makeSubviews.size(); i++) {
                MPComponentView view = makeSubviews.get(i);
                if (view.getParent() != null) {
                    ((ViewGroup)view.getParent()).removeView(view);
                }
                addView(view, new LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT));
            }
        }
    }

}
