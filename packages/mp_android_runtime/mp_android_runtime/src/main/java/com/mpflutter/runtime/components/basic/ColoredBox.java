package com.mpflutter.runtime.components.basic;

import android.content.Context;
import android.graphics.Color;

import androidx.annotation.NonNull;

import com.mpflutter.runtime.components.MPComponentView;
import com.mpflutter.runtime.components.MPUtils;
import com.mpflutter.runtime.jsproxy.JSProxyObject;

import org.json.JSONObject;

public class ColoredBox extends MPComponentView {

    public ColoredBox(@NonNull Context context) {
        super(context);
    }

    @Override
    public void setAttributes(JSProxyObject attributes) {
        super.setAttributes(attributes);
        if (attributes.has("color")) {
            setBackgroundColor(MPUtils.colorFromString(attributes.optString("color", null)));
        }
        else {
            setBackgroundColor(Color.TRANSPARENT);
        }
    }
}
