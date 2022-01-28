package com.mpflutter.runtime.components;

import android.content.Context;
import android.view.MotionEvent;
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
import com.mpflutter.runtime.jsproxy.JSProxyArray;
import com.mpflutter.runtime.jsproxy.JSProxyObject;

import org.json.JSONArray;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;

public class MPComponentView extends FrameLayout {

    public MPComponentFactory factory;
    public MPEngine engine;
    public int hashCode;
    public JSProxyObject constraints;
    public JSProxyObject attributes;
    protected JSProxyObject adjustConstraints;
    View contentView;

    public MPComponentView(@NonNull Context context) {
        super(context);
        setClipChildren(false);
    }

    public void attached() {}

    public void addContentView(View view) {
        if (view == null) return;
        contentView = view;
        addView(contentView, new LayoutParams(0, 0));
    }

    public void setConstraints(JSProxyObject constraints) {
        this.constraints = constraints;
        updateLayout();
    }

    public void setAdjustConstraints(JSProxyObject adjustConstraints) {
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
        if (getX() != MPUtils.dp2px(x, getContext())) {
            setX(MPUtils.dp2px(x, getContext()));
        }
        if (getY() != MPUtils.dp2px(y, getContext())) {
            setY(MPUtils.dp2px(y, getContext()));
        }
        if (getMinimumWidth() != MPUtils.dp2px(w, getContext())) {
            setMinimumWidth(MPUtils.dp2px(w, getContext()));
        }
        if (getMinimumHeight() != MPUtils.dp2px(h, getContext())) {
            setMinimumHeight(MPUtils.dp2px(h, getContext()));
        }
        if (contentView != null) {
            LayoutParams layoutParams = (LayoutParams) contentView.getLayoutParams();
            if (layoutParams != null && (layoutParams.width != MPUtils.dp2px(w, getContext()) || layoutParams.height != MPUtils.dp2px(h, getContext()))) {
                layoutParams.width = MPUtils.dp2px(w, getContext());
                layoutParams.height = MPUtils.dp2px(h, getContext());
                contentView.setLayoutParams(layoutParams);
            }
        }
        LayoutParams thisLayoutParams = (LayoutParams) this.getLayoutParams();
        if (thisLayoutParams != null && (thisLayoutParams.width != MPUtils.dp2px(w, getContext()) || thisLayoutParams.height != MPUtils.dp2px(h, getContext()))) {
            thisLayoutParams.width = MPUtils.dp2px(w, getContext());
            thisLayoutParams.height = MPUtils.dp2px(h, getContext());
            this.setLayoutParams(thisLayoutParams);
        }
    }

    public void setAttributes(JSProxyObject attributes) {
        this.attributes = attributes;
    }

    public void setChildren(JSProxyArray children) {
        if (children == null) return;
        List<MPComponentView> makeSubviews = new ArrayList();
        for (int i = 0; i < children.length(); i++) {
            MPComponentView view = factory.create(children.optObject(i));
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
