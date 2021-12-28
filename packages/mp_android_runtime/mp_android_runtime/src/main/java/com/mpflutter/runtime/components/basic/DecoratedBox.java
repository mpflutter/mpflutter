package com.mpflutter.runtime.components.basic;

import android.content.Context;
import android.graphics.BlendMode;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.LinearGradient;
import android.graphics.Matrix;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.Point;
import android.graphics.RadialGradient;
import android.graphics.RectF;
import android.graphics.Shader;
import android.os.Build;
import android.util.Size;
import android.view.View;

import androidx.annotation.NonNull;

import com.mpflutter.runtime.components.MPComponentView;
import com.mpflutter.runtime.components.MPUtils;
import com.mpflutter.runtime.jsproxy.JSProxyArray;
import com.mpflutter.runtime.jsproxy.JSProxyObject;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

public class DecoratedBox extends MPComponentView {

    boolean isFront = false;
    Paint backgroundPaint = new Paint();
    Paint borderPaint = new Paint();
    String color;
    JSProxyObject gradient;
    Path borderRadiusPath = new Path();
    double tlRadius = 0.0;
    double blRadius = 0.0;
    double brRadius = 0.0;
    double trRadius = 0.0;
    double borderWidth = 0.0;
    int borderColor = 0;
    Point shadowOffset;
    double shadowBlurRadius = 0;
    int shadowColor = 0;

    public DecoratedBox(@NonNull Context context) {
        super(context);
        setWillNotDraw(false);
    }

    @Override
    public void setChildren(JSProxyArray children) {
        super.setChildren(children);
        JSONObject offsetConstraints = new JSONObject();
        try {
            offsetConstraints.put("x", -borderWidth);
            offsetConstraints.put("y", -borderWidth);
        } catch (JSONException e) {
            e.printStackTrace();
        }
        for (int i = 0; i < getChildCount(); i++) {
            View view = getChildAt(i);
            if (view instanceof MPComponentView) {
                ((MPComponentView) view).setAdjustConstraints(new JSProxyObject(offsetConstraints));
            }
        }
    }

    @Override
    public void setAttributes(JSProxyObject attributes) {
        super.setAttributes(attributes);
        if (attributes.has("color")) {
            this.color = attributes.optString("color", null);
        }
        else {
            this.color = null;
        }
        JSProxyObject decoration = attributes.optObject("decoration");
        if (decoration != null && decoration.optObject("gradient") != null) {
            JSProxyObject gradient = decoration.optObject("gradient");
            this.gradient = gradient;
        }
        else {
            this.gradient = null;
        }
        if (decoration != null) {
            String borderRadiusValue = decoration.optString("borderRadius", null);
            double[] radius = new double[4];
            if (borderRadiusValue != null) {
                radius = MPUtils.cornerRadiusFromString(borderRadiusValue);
            }
            tlRadius = radius[0];
            blRadius = radius[1];
            brRadius = radius[2];
            trRadius = radius[3];
        }
        if (decoration != null && decoration.optObject("border") != null) {
            JSProxyObject border = decoration.optObject("border");
            borderWidth = border.optDouble("topWidth");
            borderColor = MPUtils.colorFromString(border.optString("topColor", null));
        }
        else {
            borderWidth = 0;
            borderColor = 0;
        }
        if (decoration != null && decoration.optArray("boxShadow") != null && decoration.optArray("boxShadow").length() > 0) {
            JSProxyObject boxShadow = decoration.optArray("boxShadow").optObject(0);
            shadowBlurRadius = boxShadow.optDouble("blurRadius");
            shadowColor = MPUtils.colorFromString(boxShadow.optString("color", null));
            shadowOffset = shadowOffsetFromValue(boxShadow.optString("offset", null));
        }
        else {
            shadowOffset = null;
            shadowColor = 0;
            shadowBlurRadius = 0;
        }
        invalidate();
    }

    void createBackgroundGradientPaint(Canvas canvas) {
        backgroundPaint.reset();
        Point startPoint = pointFromGradientLocation(gradient.optString("begin", null), canvas);
        Point endPoint = pointFromGradientLocation(gradient.optString("end", null), canvas);
        int[] colors = colorsFromGradient();
        float[] positions = positionsFromGradient();
        if (gradient.optString("classname", "").contentEquals("RadialGradient")) {
            if (colors.length == positions.length && colors.length > 0) {
                Point centerPoint = pointFromGradientLocation("center", canvas);
                RadialGradient radialGradient = new RadialGradient(centerPoint.x, centerPoint.y, Math.max(canvas.getWidth(), canvas.getHeight()) / 2, colors, positions, Shader.TileMode.CLAMP);
                backgroundPaint.setShader(radialGradient);
            }
        }
        else {
            if (colors.length == positions.length && colors.length > 0) {
                LinearGradient linearGradient = new LinearGradient(startPoint.x, startPoint.y, endPoint.x, endPoint.y, colors, positions, Shader.TileMode.CLAMP);
                backgroundPaint.setShader(linearGradient);
            }
        }
    }

    Point pointFromGradientLocation(String value, Canvas canvas) {
        if (value == null) {}
        else if (value.contentEquals("center")) {
            return new Point((int)(canvas.getWidth() * 0.5), (int)(canvas.getHeight() * 0.5));
        }
        else if (value.contentEquals("centerRight")) {
            return new Point((int)(canvas.getWidth() * 1.0), (int)(canvas.getHeight() * 0.5));
        }
        else if (value.contentEquals("centerLeft")) {
            return new Point((int)(canvas.getWidth() * 0.0), (int)(canvas.getHeight() * 0.5));
        }
        else if (value.contentEquals("topRight")) {
            return new Point((int)(canvas.getWidth() * 1.0), (int)(canvas.getHeight() * 0.0));
        }
        else if (value.contentEquals("bottomRight")) {
            return new Point((int)(canvas.getWidth() * 1.0), (int)(canvas.getHeight() * 1.0));
        }
        else if (value.contentEquals("topLeft")) {
            return new Point((int)(canvas.getWidth() * 0.0), (int)(canvas.getHeight() * 0.0));
        }
        else if (value.contentEquals("bottomLeft")) {
            return new Point((int)(canvas.getWidth() * 0.0), (int)(canvas.getHeight() * 1.0));
        }
        else if (value.contentEquals("topCenter")) {
            return new Point((int)(canvas.getWidth() * 0.5), (int)(canvas.getHeight() * 0.0));
        }
        else if (value.contentEquals("bottomCenter")) {
            return new Point((int)(canvas.getWidth() * 0.5), (int)(canvas.getHeight() * 1.0));
        }
        return new Point(0, 0);
    }

    int[] colorsFromGradient() {
        JSProxyArray values = gradient.optArray("colors");
        if (values != null) {
            int[] colors = new int[values.length()];
            for (int i = 0; i < values.length(); i++) {
                colors[i] = MPUtils.colorFromString(values.optString(i, null));
            }
            return colors;
        }
        else {
            return new int[0];
        }
    }

    float[] positionsFromGradient() {
        JSProxyArray values = gradient.optArray("stops");
        if (values != null) {
            float[] positions = new float[values.length()];
            for (int i = 0; i < values.length(); i++) {
                positions[i] = (float) values.optDouble(i);
            }
            return positions;
        }
        else {
            int length = gradient.optArray("colors").length();
            float[] positions = new float[length];
            for (int i = 0; i < length; i++) {
                positions[i] = (float)i / 1.0f;
            }
            return positions;
        }
    }

    Point shadowOffsetFromValue(String value) {
        if (value == null) return new Point(0, 0);
        if (value.startsWith("Offset(")) {
            String trimmedValue = value.replace("Offset(", "").replace(")", "");
            String[] parts = trimmedValue.split(",");
            if (parts.length == 2) {
                float a = Float.parseFloat(parts[0]);
                float b = Float.parseFloat(parts[1]);
                return new Point((int)a, (int)b);
            }
        }
        return new Point(0, 0);
    }

    void resetBorderRadiusPath(Canvas canvas) {
        borderRadiusPath.reset();
        double[] values = new double[4];
        values[0] = MPUtils.dp2px(tlRadius, getContext());
        values[1] = MPUtils.dp2px(blRadius, getContext());
        values[2] = MPUtils.dp2px(brRadius, getContext());
        values[3] = MPUtils.dp2px(trRadius, getContext());
        Size size = new Size(canvas.getWidth(), canvas.getHeight());
        MPUtils.drawRRectWithPath(borderRadiusPath, values, size);
    }

    void resetBorderPaint() {
        borderPaint.reset();
        borderPaint.setStyle(Paint.Style.STROKE);
        borderPaint.setColor(borderColor);
        borderPaint.setStrokeWidth(MPUtils.dp2px(borderWidth * 2, getContext()));
    }

    void resetShadowPaint() {
        if (shadowColor != 0) {
            backgroundPaint.setShadowLayer(MPUtils.dp2px(shadowBlurRadius, getContext()), MPUtils.dp2px(shadowOffset.x, getContext()), MPUtils.dp2px(shadowOffset.y, getContext()), shadowColor);
            setLayerType(LAYER_TYPE_SOFTWARE, backgroundPaint);
        }
        else {
            backgroundPaint.clearShadowLayer();
            setLayerType(LAYER_TYPE_NONE, backgroundPaint);
        }
    }

    @Override
    public void draw(Canvas canvas) {
        if (isFront) {
            super.draw(canvas);
        }
        canvas.save();
        resetBorderRadiusPath(canvas);
        if (gradient != null) {
            createBackgroundGradientPaint(canvas);
            canvas.clipPath(borderRadiusPath);
            resetShadowPaint();
            canvas.drawRect(new RectF(0, 0, canvas.getWidth(), canvas.getHeight()), backgroundPaint);
        }
        else if (color != null) {
            backgroundPaint.reset();
            backgroundPaint.setColor(MPUtils.colorFromString(color));
            canvas.clipPath(borderRadiusPath);
            resetShadowPaint();
            canvas.drawRect(new RectF(0, 0, canvas.getWidth(), canvas.getHeight()), backgroundPaint);
        }
        if (borderColor != 0 && borderWidth > 0) {
            resetBorderPaint();
            canvas.drawPath(borderRadiusPath, borderPaint);
        }
        canvas.restore();
        if (!isFront) {
            super.draw(canvas);
        }
    }
}
