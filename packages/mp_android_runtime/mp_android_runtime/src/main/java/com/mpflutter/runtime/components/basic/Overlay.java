package com.mpflutter.runtime.components.basic;

import android.content.Context;
import android.view.View;

import androidx.annotation.NonNull;

import com.mpflutter.runtime.components.MPComponentView;
import com.mpflutter.runtime.jsproxy.JSProxyObject;

import org.json.JSONObject;

import java.util.HashMap;

public class Overlay extends MPComponentView {

    public boolean onBackgroundTap = false;

    public Overlay(@NonNull Context context) {
        super(context);
        setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View view) {
                onBackPressed();
            }
        });
    }

    @Override
    public void setAttributes(JSProxyObject attributes) {
        super.setAttributes(attributes);
        onBackgroundTap = !attributes.isNull("onBackgroundTap");
    }

    public void onBackPressed() {
        if (!onBackgroundTap) return;
        engine.sendMessage(new HashMap(){{
            put("type", "overlay");
            put("message", new HashMap(){{
                put("event", "onBackgroundTap");
                put("target", hashCode);
            }});
        }});
    }
}
