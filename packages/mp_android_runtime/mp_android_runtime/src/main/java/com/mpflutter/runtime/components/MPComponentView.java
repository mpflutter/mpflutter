package com.mpflutter.runtime.components;

import android.content.Context;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewParent;
import android.widget.FrameLayout;

import androidx.annotation.NonNull;

import com.mpflutter.runtime.MPEngine;
import com.mpflutter.runtime.components.basic.DecoratedBox;
import com.mpflutter.runtime.components.basic.GestureDetector;
import com.mpflutter.runtime.components.basic.Offstage;
import com.mpflutter.runtime.components.basic.Visibility;
import com.mpflutter.runtime.components.mpkit.MPPlatformView;
import com.mpflutter.runtime.components.mpkit.MPScaffold;

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
    View contentView;

    public MPComponentView(@NonNull Context context) {
        super(context);
        setClipChildren(false);
    }

    public void addContentView(View view) {
        if (view == null) return;
        contentView = view;
        addView(contentView, new LayoutParams(0, 0));
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
        if (this.adjustConstraints != null && (this.getParent() instanceof GestureDetector || this.getParent() instanceof Visibility || this.getParent() instanceof DecoratedBox || this.getParent() instanceof MPPlatformView)) {
            x -= this.adjustConstraints.optDouble("x", 0.0);
            y -= this.adjustConstraints.optDouble("y", 0.0);
        }
        setX(MPUtils.dp2px(x, getContext()));
        setY((MPUtils.dp2px(y, getContext())));
        setMinimumWidth(MPUtils.dp2px(w, getContext()));
        setMinimumHeight(MPUtils.dp2px(h, getContext()));
        if (contentView != null) {
            LayoutParams layoutParams = (LayoutParams) contentView.getLayoutParams();
            layoutParams.width = MPUtils.dp2px(w, getContext());
            layoutParams.height = MPUtils.dp2px(h, getContext());
            contentView.setLayoutParams(layoutParams);
        }
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

    public void removeFromSuperview() {
        if (getParent() != null) {
            ((ViewGroup)getParent()).removeView(this);
        }
    }

    public MPScaffold getScaffold() {
        ViewParent parent = getParent();
        while (parent != null) {
            if (parent != null && parent instanceof MPScaffold) {
                return (MPScaffold) parent;
            }
            parent = parent.getParent();
        }
        return null;
    }

}
