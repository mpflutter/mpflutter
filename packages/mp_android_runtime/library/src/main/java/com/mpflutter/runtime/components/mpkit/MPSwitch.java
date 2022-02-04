package com.mpflutter.runtime.components.mpkit;

import android.content.Context;
import android.graphics.Color;
import android.widget.CompoundButton;

import androidx.annotation.NonNull;

import com.google.android.material.switchmaterial.SwitchMaterial;
import com.mpflutter.runtime.jsproxy.JSProxyArray;
import com.mpflutter.runtime.jsproxy.JSProxyObject;

import org.json.JSONArray;
import org.json.JSONObject;

import java.util.HashMap;

public class MPSwitch extends MPPlatformView {

    SwitchMaterial contentView;
    boolean firstSetted = false;

    public MPSwitch(@NonNull Context context) {
        super(context);
        contentView = new SwitchMaterial(context);
        addContentView(contentView);
        contentView.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton compoundButton, boolean b) {
                invokeMethod("onValueChanged", new HashMap(){{
                    put("value", contentView.isChecked());
                }});
            }
        });
    }

    @Override
    public void setChildren(JSProxyArray children) { }

    @Override
    public void setAttributes(JSProxyObject attributes) {
        super.setAttributes(attributes);
        if (!firstSetted) {
            firstSetted = true;
            contentView.setChecked(attributes.optBoolean("defaultValue", false));
        }
    }

    @Override
    public void onMethodCall(String method, Object params, MPPlatformViewCallback callback) {
        if (method.contentEquals("setValue") && params instanceof JSProxyObject) {
            boolean value = ((JSProxyObject) params).optBoolean("value", false);
            contentView.setChecked(value);
        }
    }
}
