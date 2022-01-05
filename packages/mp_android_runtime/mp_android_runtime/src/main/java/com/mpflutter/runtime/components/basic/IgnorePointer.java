package com.mpflutter.runtime.components.basic;

import android.content.Context;
import android.view.MotionEvent;

import androidx.annotation.NonNull;

import com.mpflutter.runtime.components.MPComponentView;
import com.mpflutter.runtime.jsproxy.JSProxyObject;

import org.json.JSONObject;

public class IgnorePointer extends MPComponentView {

    boolean ignoring = false;

    public IgnorePointer(@NonNull Context context) {
        super(context);
    }

    @Override
    public void setAttributes(JSProxyObject attributes) {
        super.setAttributes(attributes);
        this.ignoring = attributes.optBoolean("ignoring", false);
    }

    @Override
    public boolean dispatchTouchEvent(MotionEvent ev) {
        if (ignoring) {
            return true;
        }
        return super.dispatchTouchEvent(ev);
    }
}
