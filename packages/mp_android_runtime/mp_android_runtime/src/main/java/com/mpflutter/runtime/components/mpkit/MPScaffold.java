package com.mpflutter.runtime.components.mpkit;

import android.content.Context;
import android.graphics.Color;
import android.view.ViewGroup;
import android.widget.FrameLayout;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;

import com.mpflutter.runtime.components.MPComponentView;
import com.mpflutter.runtime.components.MPUtils;

import org.json.JSONArray;
import org.json.JSONObject;

public class MPScaffold extends MPComponentView {

    MPComponentView appBar;
    MPComponentView body;
    MPComponentView bottomBar;
    MPComponentView floatingBody;
    public Context rootViewContext;

    public MPScaffold(@NonNull Context context) {
        super(context);
    }

    @Override
    public void setAttributes(JSONObject attributes) {
        super.setAttributes(attributes);
        setWillNotDraw(false);
        this.setBody(factory.create(attributes.optJSONObject("body")));
        this.setAppBar(factory.create(attributes.optJSONObject("appBar")));
        this.setBottomBar(factory.create(attributes.optJSONObject("bottomBar")));
        this.setFloatingBody(factory.create(attributes.optJSONObject("floatingBody")));
        String backgroundColor = attributes.optString("backgroundColor");
        if (backgroundColor != null && backgroundColor != "null") {
            setBackgroundColor(MPUtils.colorFromString(backgroundColor));
        }
        else {
            setBackgroundColor(Color.WHITE);
        }
        resetNavigationItems();
    }

    @Override
    public void setChildren(JSONArray children) { }

    private void setBody(MPComponentView body) {
        if (body == this.body) return;
        this.body = body;
        this.reAddSubviews();
    }

    private void setAppBar(MPComponentView appBar) {
        if (appBar == this.appBar) return;
        this.appBar = appBar;
        this.reAddSubviews();
    }

    private void setBottomBar(MPComponentView bottomBar) {
        if (bottomBar == this.bottomBar) return;
        this.bottomBar = bottomBar;
        this.reAddSubviews();
    }

    private void setFloatingBody(MPComponentView floatingBody) {
        if (floatingBody == this.floatingBody) return;
        this.floatingBody = floatingBody;
        this.reAddSubviews();
    }

    private void reAddSubviews() {
        removeAllViews();
        if (this.body != null) {
            addView(this.body, new FrameLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT));
        }
        if (this.appBar != null) {
            addView(this.appBar, new FrameLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT));
        }
        if (this.bottomBar != null) {
            addView(this.bottomBar, new FrameLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT));
        }
        if (this.floatingBody != null) {
            addView(this.floatingBody, new FrameLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT));
        }
    }

    public void resetNavigationItems() {
        if (attributes == null) return;
        AppCompatActivity activity = activity();
        if (activity == null) return;
        String title = attributes.optString("name");
        if (!MPUtils.isNull(title)) {
            androidx.appcompat.app.ActionBar actionBar = activity.getSupportActionBar();
            if (actionBar != null) {
                actionBar.setTitle(title);
            }
        }
        else {
            androidx.appcompat.app.ActionBar actionBar = activity.getSupportActionBar();
            if (actionBar != null) {
                actionBar.setTitle("");
            }
        }
    }

    private AppCompatActivity activity() {
        if (rootViewContext instanceof AppCompatActivity) {
            return (AppCompatActivity)rootViewContext;
        }
        return null;
    }
}
