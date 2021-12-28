package com.mpflutter.runtime.components.mpkit;

import android.content.Context;
import android.graphics.Color;
import android.view.ViewGroup;
import android.widget.FrameLayout;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;

import com.mpflutter.runtime.components.MPComponentView;
import com.mpflutter.runtime.components.MPUtils;
import com.mpflutter.runtime.jsproxy.JSProxyArray;
import com.mpflutter.runtime.jsproxy.JSProxyObject;

import org.json.JSONArray;
import org.json.JSONObject;

import java.util.HashMap;

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
    public void setAttributes(JSProxyObject attributes) {
        super.setAttributes(attributes);
        setWillNotDraw(false);
        this.setBody(factory.create(attributes.optObject("body")));
        this.setAppBar(factory.create(attributes.optObject("appBar")));
        this.setBottomBar(factory.create(attributes.optObject("bottomBar")));
        this.setFloatingBody(factory.create(attributes.optObject("floatingBody")));
        String backgroundColor = attributes.optString("backgroundColor", null);
        if (backgroundColor != null) {
            setBackgroundColor(MPUtils.colorFromString(backgroundColor));
        }
        else {
            setBackgroundColor(Color.WHITE);
        }
        resetNavigationItems();
    }

    @Override
    public void setChildren(JSProxyArray children) { }

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
            this.body.removeFromSuperview();
            addView(this.body, new FrameLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT));
        }
        if (this.appBar != null) {
            this.appBar.removeFromSuperview();
            addView(this.appBar, new FrameLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT));
        }
        if (this.bottomBar != null) {
            this.bottomBar.removeFromSuperview();
            addView(this.bottomBar, new FrameLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT));
        }
        if (this.floatingBody != null) {
            this.floatingBody.removeFromSuperview();
            addView(this.floatingBody, new FrameLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT));
        }
    }

    public void resetNavigationItems() {
        if (attributes == null) return;
        AppCompatActivity activity = activity();
        if (activity == null) return;
        String title = attributes.optString("name", null);
        if (title != null) {
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

    public void onReachBottom() {
        engine.sendMessage(new HashMap(){{
            put("type", "scaffold");
            put("message", new HashMap(){{
                put("event", "onReachBottom");
                put("target", hashCode);
            }});
        }});
    }

    public void onPageScroll(double scrollTop) {
        engine.sendMessage(new HashMap(){{
            put("type", "scaffold");
            put("message", new HashMap(){{
                put("event", "onPageScroll");
                put("target", hashCode);
                put("scrollTop", scrollTop);
            }});
        }});
    }

    private AppCompatActivity activity() {
        if (rootViewContext instanceof AppCompatActivity) {
            return (AppCompatActivity)rootViewContext;
        }
        return null;
    }
}
