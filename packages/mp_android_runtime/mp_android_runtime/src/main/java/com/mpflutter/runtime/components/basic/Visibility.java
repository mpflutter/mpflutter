package com.mpflutter.runtime.components.basic;

import android.content.Context;
import android.view.View;

import androidx.annotation.NonNull;

import com.mpflutter.runtime.components.MPComponentView;
import com.mpflutter.runtime.jsproxy.JSProxyArray;
import com.mpflutter.runtime.jsproxy.JSProxyObject;

import org.json.JSONArray;
import org.json.JSONObject;

public class Visibility extends MPComponentView {
    public Visibility(@NonNull Context context) {
        super(context);
    }

    @Override
    public void setChildren(JSProxyArray children) {
        super.setChildren(children);
        for (int i = 0; i < getChildCount(); i++) {
            View view = getChildAt(i);
            if (view instanceof MPComponentView) {
                ((MPComponentView) view).setAdjustConstraints(this.constraints);
            }
        }
    }

    @Override
    public void setAttributes(JSProxyObject attributes) {
        super.setAttributes(attributes);
        Boolean visible = attributes.has("visible") ? attributes.optBoolean("visible", false) : null;
        if (visible != null && !visible) {
            setVisibility(INVISIBLE);
        }
        else {
            setVisibility(VISIBLE);
        }
    }
}
