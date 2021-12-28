package com.mpflutter.runtime.components.mpkit;

import android.content.Context;

import androidx.annotation.NonNull;

import com.google.android.material.slider.Slider;
import com.mpflutter.runtime.jsproxy.JSProxyArray;

import org.json.JSONArray;

public class MPSlider extends MPPlatformView {

    Slider contentView;

    public MPSlider(@NonNull Context context) {
        super(context);
        contentView = new Slider(context);
        addContentView(contentView);
    }

    @Override
    public void setChildren(JSProxyArray children) { }
}
