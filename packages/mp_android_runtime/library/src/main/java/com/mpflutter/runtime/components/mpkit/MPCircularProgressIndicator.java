package com.mpflutter.runtime.components.mpkit;

import android.content.Context;
import android.graphics.Color;
import android.view.View;

import androidx.annotation.NonNull;

import com.mpflutter.runtime.components.MPUtils;
import com.mpflutter.runtime.jsproxy.JSProxyArray;
import com.mpflutter.runtime.jsproxy.JSProxyObject;

public class MPCircularProgressIndicator extends MPPlatformView {

    View contentView;

    public MPCircularProgressIndicator(@NonNull Context context) {
        super(context);
    }

    @Override
    public void attached() {
        super.attached();
        contentView = engine.provider.uiProvider.createCircularProgressIndicator(getContext());
        addContentView(contentView);
    }

    @Override
    public void setChildren(JSProxyArray children) { }

    @Override
    public void setAttributes(JSProxyObject attributes) {
        super.setAttributes(attributes);
        engine.provider.uiProvider.setCircularProgressIndicatorAttributes(
                contentView,
                MPUtils.colorFromString(attributes.optString("color", null)),
                MPUtils.dp2px(attributes.optDouble("size", 36.0), getContext())
                );
    }
}
