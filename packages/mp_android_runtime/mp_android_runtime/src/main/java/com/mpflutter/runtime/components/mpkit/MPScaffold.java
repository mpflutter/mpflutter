package com.mpflutter.runtime.components.mpkit;

import android.content.Context;
import android.graphics.Color;
import android.view.ViewGroup;
import android.widget.FrameLayout;

import androidx.annotation.NonNull;

import com.mpflutter.runtime.components.MPComponentView;

import org.json.JSONArray;
import org.json.JSONObject;

public class MPScaffold extends MPComponentView {

    MPComponentView body;

    public MPScaffold(@NonNull Context context) {
        super(context);
    }

    @Override
    public void setAttributes(JSONObject attributes) {
        super.setAttributes(attributes);
        setWillNotDraw(false);
        this.setBody(factory.create(attributes.optJSONObject("body")));
    }

    @Override
    public void setChildren(JSONArray children) { }

    private void setBody(MPComponentView body) {
        if (body == this.body) return;
        this.body = body;
        this.reAddSubviews();
    }

    private void reAddSubviews() {
        removeAllViews();
        if (this.body != null) {
            addView(this.body, new FrameLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT));
        }
    }
}
