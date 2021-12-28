package com.mpflutter.runtime.components.mpkit;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.PorterDuff;
import android.graphics.PorterDuffColorFilter;

import androidx.annotation.NonNull;

import com.facebook.drawee.view.SimpleDraweeView;
import com.mpflutter.runtime.components.MPComponentView;
import com.mpflutter.runtime.components.MPUtils;
import com.mpflutter.runtime.jsproxy.JSProxyArray;
import com.mpflutter.runtime.jsproxy.JSProxyObject;

import org.json.JSONArray;
import org.json.JSONObject;

public class MPIcon extends MPComponentView {

    SimpleDraweeView contentView;
    int tintColor = 0;

    public MPIcon(@NonNull Context context) {
        super(context);
        contentView = new SimpleDraweeView(context) {
            @Override
            public void draw(Canvas canvas) {
                if (tintColor != 0) {
                    Bitmap bitmap = Bitmap.createBitmap(canvas.getWidth(), canvas.getHeight(), Bitmap.Config.ARGB_8888);
                    Canvas offscreenCanvas = new Canvas(bitmap);
                    super.draw(offscreenCanvas);
                    Paint paint = new Paint();
                    paint.setColorFilter(new PorterDuffColorFilter(tintColor, PorterDuff.Mode.SRC_IN));
                    canvas.drawBitmap(bitmap, 0,0, paint);
                    bitmap.recycle();
                }
                else {
                    super.draw(canvas);
                }
            }
        };
        addContentView(contentView);
    }

    @Override
    public void setChildren(JSProxyArray children) { }

    @Override
    public void setAttributes(JSProxyObject attributes) {
        super.setAttributes(attributes);
        String iconUrl = attributes.optString("iconUrl", null);
        if (iconUrl != null && iconUrl != "null") {
            contentView.setImageURI(iconUrl);
        }
        String color = attributes.optString("color", null);
        if (color != null && color != "null") {
            tintColor = MPUtils.colorFromString(color);
        }
    }

}
