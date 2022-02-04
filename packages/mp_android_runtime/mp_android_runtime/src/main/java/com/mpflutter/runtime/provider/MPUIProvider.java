package com.mpflutter.runtime.provider;

import android.content.Context;
import android.graphics.Color;
import android.view.View;

import com.google.android.material.progressindicator.CircularProgressIndicator;
import com.mpflutter.runtime.components.MPUtils;

public class MPUIProvider {

    public MPUIProvider(Context context) {

    }

    public View createCircularProgressIndicator(Context context) {
        return null;
    }

    public void setCircularProgressIndicatorAttributes(View view, int color, int size) {}

    static public class DefaultProvider extends MPUIProvider {

        public DefaultProvider(Context context) {
            super(context);
        }

        @Override
        public View createCircularProgressIndicator(Context context) {
            CircularProgressIndicator view = new CircularProgressIndicator(context);
            view.setIndeterminate(true);
            return view;
        }

        @Override
        public void setCircularProgressIndicatorAttributes(View view, int color, int size) {
            if (view instanceof CircularProgressIndicator) {
                ((CircularProgressIndicator) view).setIndicatorColor(color);
                ((CircularProgressIndicator) view).setIndicatorSize(size - MPUtils.dp2px(6, view.getContext()));
            }
        }
    }
}
