package com.mpflutter.runtime.components.mpkit;

import android.content.Context;
import android.graphics.Color;

import androidx.annotation.NonNull;

import com.google.android.material.slider.Slider;
import com.mpflutter.runtime.jsproxy.JSProxyArray;
import com.mpflutter.runtime.jsproxy.JSProxyObject;

import org.json.JSONArray;

import java.util.HashMap;

public class MPSlider extends MPPlatformView {

    Slider contentView;
    boolean firstSetted = false;

    public MPSlider(@NonNull Context context) {
        super(context);
        contentView = new Slider(context);
        contentView.addOnChangeListener(new Slider.OnChangeListener() {
            @Override
            public void onValueChange(@NonNull Slider slider, float value, boolean fromUser) {
                invokeMethod("onValueChanged", new HashMap(){{
                    put("value", value);
                }});
            }
        });
        addContentView(contentView);
    }

    @Override
    public void setChildren(JSProxyArray children) { }

    @Override
    public void setAttributes(JSProxyObject attributes) {
        super.setAttributes(attributes);
        float min = (float) attributes.optDouble("min", 0.0);
        if (contentView.getValueFrom() != min) {
            contentView.setValueFrom(min);
        }
        float max = (float) attributes.optDouble("max", 1.0);
        if (contentView.getValueTo() != max) {
            contentView.setValueTo(max);
        }
        if (attributes.has("step")) {
            float step = (float) attributes.optDouble("step", 0.01f);
            if (contentView.getStepSize() != step) {
                contentView.setStepSize(step);
            }
        }
        if (!firstSetted) {
            firstSetted = true;
            if (attributes.has("defaultValue")) {
                double defaultValue = attributes.optDouble("defaultValue", 0.0);
                contentView.setValue((float) defaultValue);
            }
        }
    }

    @Override
    public void onMethodCall(String method, Object params, MPPlatformViewCallback callback) {
        super.onMethodCall(method, params, callback);
        if (method.contentEquals("setValue") && params instanceof JSProxyObject) {
            float v = (float) ((JSProxyObject) params).optDouble("value", 0.0);
            v = Math.max(contentView.getValueFrom(), Math.min(contentView.getValueTo(), v));
            contentView.setValue(v);
        }
    }
}
