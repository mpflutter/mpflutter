package com.mpflutter.runtime.components.basic;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Matrix;

import androidx.annotation.NonNull;

import com.mpflutter.runtime.components.MPComponentView;
import com.mpflutter.runtime.components.MPUtils;
import com.mpflutter.runtime.jsproxy.JSProxyObject;

import org.json.JSONObject;

import java.util.List;

public class Transform extends MPComponentView {

    Matrix transformMatrix = new Matrix();

    public Transform(@NonNull Context context) {
        super(context);
        setWillNotDraw(false);
    }

    @Override
    public void setAttributes(JSProxyObject attributes) {
        super.setAttributes(attributes);
        String transform = attributes.optString("transform", null);
        if (transform != null) {
            transform = transform.replace("matrix(", "");
            transform = transform.replace(")", "");
            String[] parts = transform.split(",");
            if (parts.length == 6) {
                float a = Float.parseFloat(parts[0]);
                float b = Float.parseFloat(parts[1]);
                float c = Float.parseFloat(parts[2]);
                float d = Float.parseFloat(parts[3]);
                float tx = Float.parseFloat(parts[4]);
                float ty = Float.parseFloat(parts[5]);
                final float[] values = { a, c, tx, b, d, ty, 0.0f, 0.0f, 1.0f };
                transformMatrix = new Matrix();
                transformMatrix.setValues(values);
            }
        }
        else {
            transformMatrix = new Matrix();
        }
        invalidate();
    }

    @Override
    public void draw(Canvas canvas) {
        canvas.save();
        canvas.translate(canvas.getWidth() / 2, canvas.getHeight() / 2);
        canvas.concat(transformMatrix);
        canvas.translate(-canvas.getWidth() / 2, -canvas.getHeight() / 2);
        super.draw(canvas);
        canvas.restore();
    }
}
