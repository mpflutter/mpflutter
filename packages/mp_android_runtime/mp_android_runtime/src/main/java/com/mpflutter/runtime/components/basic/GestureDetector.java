package com.mpflutter.runtime.components.basic;

import android.content.Context;
import android.view.View;

import androidx.annotation.NonNull;

import com.mpflutter.runtime.components.MPComponentView;

import org.json.JSONArray;
import org.json.JSONObject;

import java.util.HashMap;

public class GestureDetector extends MPComponentView {

    public GestureDetector(@NonNull Context context) {
        super(context);
    }

    @Override
    public void setChildren(JSONArray children) {
        super.setChildren(children);
        for (int i = 0; i < getChildCount(); i++) {
            View view = getChildAt(i);
            if (view instanceof MPComponentView) {
                ((MPComponentView) view).setAdjustConstraints(this.constraints);
            }
        }
    }

    @Override
    public void setAttributes(JSONObject attributes) {
        super.setAttributes(attributes);
        if (attributes.has("onTap")) {
            setOnClickListener(new OnClickListener() {
                @Override
                public void onClick(View view) {
                    if (GestureDetector.this.attributes != null && GestureDetector.this.attributes.has("onTap")) {
                        engine.sendMessage(new HashMap(){{
                            put("type", "gesture_detector");
                            put("message", new HashMap(){{
                                put("event", "onTap");
                                put("target", GestureDetector.this.hashCode);
                            }});
                        }});
                    }
                }
            });
        }
    }
}
