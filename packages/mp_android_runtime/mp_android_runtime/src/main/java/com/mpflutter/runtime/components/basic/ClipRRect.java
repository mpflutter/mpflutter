package com.mpflutter.runtime.components.basic;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.RectF;
import android.util.Size;

import androidx.annotation.NonNull;

import com.mpflutter.runtime.components.MPComponentView;
import com.mpflutter.runtime.components.MPUtils;
import com.mpflutter.runtime.jsproxy.JSProxyObject;

import org.json.JSONObject;

public class ClipRRect extends MPComponentView {

    Path clipPath = new Path();
    double tlRadius = 0.0;
    double blRadius = 0.0;
    double brRadius = 0.0;
    double trRadius = 0.0;

    public ClipRRect(@NonNull Context context) {
        super(context);
        setWillNotDraw(false);
    }

    @Override
    public void setAttributes(JSProxyObject attributes) {
        super.setAttributes(attributes);
        String borderRadiusValue = attributes.optString("borderRadius", null);
        double[] radius = new double[4];
        if (borderRadiusValue != null) {
            radius = MPUtils.cornerRadiusFromString(borderRadiusValue);
        }
        if (radius[0] != tlRadius || radius[1] != blRadius || radius[2] != brRadius || radius[3] != trRadius) {
            tlRadius = radius[0];
            blRadius = radius[1];
            brRadius = radius[2];
            trRadius = radius[3];
            invalidate();
        }
    }

    @Override
    public void draw(Canvas canvas) {
        clipPath.reset();
        double[] values = new double[4];
        values[0] = MPUtils.dp2px(tlRadius, getContext());
        values[1] = MPUtils.dp2px(blRadius, getContext());
        values[2] = MPUtils.dp2px(brRadius, getContext());
        values[3] = MPUtils.dp2px(trRadius, getContext());
        Size size = new Size(canvas.getWidth(), canvas.getHeight());
        MPUtils.drawRRectWithPath(clipPath, values, size);
        canvas.save();
        canvas.clipPath(clipPath);
        super.draw(canvas);
        canvas.restore();
    }
}
