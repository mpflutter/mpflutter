package com.mpflutter.sample;

import android.content.Context;
import android.graphics.Color;
import android.view.Gravity;
import android.view.View;
import android.widget.TextView;

import androidx.annotation.NonNull;

import com.mpflutter.runtime.components.mpkit.MPPlatformView;
import com.mpflutter.runtime.jsproxy.JSProxyArray;
import com.mpflutter.runtime.jsproxy.JSProxyObject;

import java.util.HashMap;

public class TemplateFooView extends MPPlatformView {

    TextView contentView;

    public TemplateFooView(@NonNull Context context) {
        super(context);
        contentView = new TextView(context);
        contentView.setGravity(Gravity.CENTER);
        addContentView(contentView);
        setBackgroundColor(Color.YELLOW);
        setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View view) {
                invokeMethod("xxx", new HashMap(){{
                    put("yyy", "kkk");
                }});
            }
        });
    }

    @Override
    public void setAttributes(JSProxyObject attributes) {
        super.setAttributes(attributes);
        contentView.setText(attributes.optString("text", ""));
    }

    @Override
    public void setChildren(JSProxyArray children) { }
}
