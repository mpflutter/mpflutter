package com.mpflutter.runtime.components.basic;

import android.content.Context;

import androidx.annotation.NonNull;

import com.mpflutter.runtime.components.MPComponentView;
import com.mpflutter.runtime.jsproxy.JSProxyObject;

import org.json.JSONObject;

public class Offstage extends MPComponentView {
    public Offstage(@NonNull Context context) {
        super(context);
    }

    @Override
    public void setAttributes(JSProxyObject attributes) {
        super.setAttributes(attributes);
        Boolean offstage = attributes.has("offstage") ? attributes.optBoolean("offstage", false) : null;
        if (offstage != null && offstage) {
            setVisibility(INVISIBLE);
        }
        else {
            setVisibility(VISIBLE);
        }
    }
}
