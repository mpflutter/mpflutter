package com.mpflutter.runtime.components.basic;

import android.content.Context;

import androidx.annotation.NonNull;

import com.mpflutter.runtime.components.MPComponentView;
import com.mpflutter.runtime.jsproxy.JSProxyObject;

import org.json.JSONObject;

public class Opacity extends MPComponentView {
    public Opacity(@NonNull Context context) {
        super(context);
    }

    @Override
    public void setAttributes(JSProxyObject attributes) {
        super.setAttributes(attributes);
        this.setAlpha((float)attributes.optDouble("opacity", 1.0));
    }
}

