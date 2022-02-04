package com.mpflutter.runtime.components.basic;

import android.content.Context;
import android.graphics.Canvas;

import androidx.annotation.NonNull;

public class ForegroundDecoratedBox extends DecoratedBox {

    public ForegroundDecoratedBox(@NonNull Context context) {
        super(context);
        isFront = true;
        setWillNotDraw(false);
    }

}
