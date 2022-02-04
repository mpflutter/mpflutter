package com.mpflutter.runtime.components.basic;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Path;
import android.graphics.RectF;

import androidx.annotation.NonNull;

import com.mpflutter.runtime.components.MPComponentView;

public class ClipOval extends MPComponentView {

    Path ovalPath = new Path();

    public ClipOval(@NonNull Context context) {
        super(context);
        setWillNotDraw(false);
    }

    @Override
    public void draw(Canvas canvas) {
        ovalPath.reset();
        ovalPath.addOval(new RectF(0, 0, canvas.getWidth(), canvas.getHeight()), Path.Direction.CCW);
        canvas.save();
        canvas.clipPath(ovalPath);
        super.draw(canvas);
        canvas.restore();
    }
}
