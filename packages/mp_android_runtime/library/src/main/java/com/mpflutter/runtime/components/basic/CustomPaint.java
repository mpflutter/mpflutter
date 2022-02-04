package com.mpflutter.runtime.components.basic;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BlendMode;
import android.graphics.Canvas;
import android.graphics.Matrix;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.PorterDuff;
import android.graphics.Rect;
import android.graphics.RectF;
import android.os.Build;
import android.util.Base64;
import android.util.Log;

import androidx.annotation.NonNull;

import com.mpflutter.runtime.MPEngine;
import com.mpflutter.runtime.components.MPComponentView;
import com.mpflutter.runtime.components.MPUtils;
import com.mpflutter.runtime.jsproxy.JSProxyArray;
import com.mpflutter.runtime.jsproxy.JSProxyObject;

import org.json.JSONArray;

import java.io.ByteArrayOutputStream;
import java.util.HashMap;

public class CustomPaint extends MPComponentView {

    public static void didReceivedCustomPaintMessage(JSProxyObject message, MPEngine engine) {
        String event = message.optString("event", null);
        if (event == null) return;
        if (event.contentEquals("fetchImage")) {
            int target = message.optInt("target", 0);
            MPComponentView targetView = engine.componentFactory.cachedView.get(target);
            if (targetView instanceof CustomPaint) {
                CustomPaint customPaint = (CustomPaint) targetView;
                Bitmap offscreenBitmap = Bitmap.createBitmap(customPaint.getWidth(), customPaint.getHeight(), Bitmap.Config.ARGB_8888);
                Canvas offscreenCanvas = new Canvas(offscreenBitmap);
                customPaint.draw(offscreenCanvas);
                ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
                offscreenBitmap.compress(Bitmap.CompressFormat.PNG, 100, byteArrayOutputStream);
                offscreenBitmap.recycle();
                String base64EncodedData = Base64.encodeToString(byteArrayOutputStream.toByteArray(), Base64.NO_WRAP);
                engine.sendMessage(new HashMap(){{
                    put("type", "custom_paint");
                    put("message", new HashMap(){{
                        put("event", "onFetchImageResult");
                        put("seqId", message.optString("seqId", null));
                        put("data", base64EncodedData);
                    }});
                }});
            }
        }
    }

    JSProxyArray commands;

    public CustomPaint(@NonNull Context context) {
        super(context);
        setWillNotDraw(false);
    }

    @Override
    public void setChildren(JSProxyArray children) { }

    @Override
    public void setAttributes(JSProxyObject attributes) {
        super.setAttributes(attributes);
        this.commands = attributes.optArray("commands");
        invalidate();
    }

    void drawRect(JSProxyObject cmd, Canvas canvas, Paint paint) {
        double x = cmd.optDouble("x") * MPUtils.scale(getContext());
        double y = cmd.optDouble("y") * MPUtils.scale(getContext());
        double width = cmd.optDouble("width") * MPUtils.scale(getContext());
        double height = cmd.optDouble("height") * MPUtils.scale(getContext());
        setPaint(cmd.optObject("paint"), paint);
        canvas.drawRect(
                (int)x,
                (int)y,
                (int)(x + width),
                (int)(y + height),
                paint);
    }

    void drawDRRect(JSProxyObject cmd, Canvas canvas, Paint paint) {
        Path outer = pathWithParams(cmd.optObject("outer"));
        Path inner = pathWithParams(cmd.optObject("inner"));
        outer.addPath(inner);
        outer.setFillType(Path.FillType.EVEN_ODD);
        setPaint(cmd.optObject("paint"), paint);
        canvas.drawPath(outer, paint);
    }

    void drawPath(JSProxyObject cmd, Canvas canvas, Paint paint) {
        Path bezierPath = pathWithParams(cmd.optObject("path"));
        setPaint(cmd.optObject("paint"), paint);
        canvas.drawPath(bezierPath, paint);
    }

    void clipPath(JSProxyObject cmd, Canvas canvas, Paint paint) {
        Path bezierPath = pathWithParams(cmd.optObject("path"));
        setPaint(cmd.optObject("paint"), paint);
        canvas.clipPath(bezierPath);
    }

    void drawColor(JSProxyObject cmd, Canvas canvas, Paint paint) {
//        String blendMode = cmd.optString("blendMode", null);
        String color = cmd.optString("color", null);
        canvas.drawColor(MPUtils.colorFromString(color));
    }

    void drawImage(JSProxyObject cmd, Canvas canvas, Paint paint) {
        int drawable = cmd.optInt("drawable", 0);
        if (drawable == 0) return;
        Bitmap image = engine.drawableStorage.decodedDrawables.get(drawable);
        if (image == null) return;
        double x = cmd.optDouble("dx", 0.0) * MPUtils.scale(getContext());
        double y = cmd.optDouble("dy", 0.0) * MPUtils.scale(getContext());
        setPaint(cmd.optObject("paint"), paint);
        canvas.drawBitmap(image, (float)x, (float)y, paint);
    }

    void drawImageRect(JSProxyObject cmd, Canvas canvas, Paint paint) {
        int drawable = cmd.optInt("drawable", 0);
        if (drawable == 0) return;
        Bitmap image = engine.drawableStorage.decodedDrawables.get(drawable);
        if (image == null) return;
        double srcX = cmd.optDouble("srcX", 0.0);
        double srcY = cmd.optDouble("srcY", 0.0);
        double srcW = cmd.optDouble("srcW", 0.0);
        double srcH = cmd.optDouble("srcH", 0.0);
        double dstX = cmd.optDouble("dstX", 0.0) * MPUtils.scale(getContext());
        double dstY = cmd.optDouble("dstY", 0.0) * MPUtils.scale(getContext());
        double dstW = cmd.optDouble("dstW", 0.0) * MPUtils.scale(getContext());
        double dstH = cmd.optDouble("dstH", 0.0) * MPUtils.scale(getContext());
        setPaint(cmd.optObject("paint"), paint);
        canvas.drawBitmap(
                image,
                new Rect((int)srcX, (int)srcY, (int)(srcX + srcW), (int)(srcY + srcH)),
                new RectF((float)dstX, (float)dstY, (float)(dstX + dstW), (float)(dstY + dstH)),
                paint
                );
    }

    Path pathWithParams(JSProxyObject path) {
        Path bezierPath = new Path();
        if (path == null) {
            return bezierPath;
        }
        JSProxyArray commands = path.optArray("commands");
        if (commands == null) {
            return bezierPath;
        }
        int lastX = 0;
        int lastY = 0;
        for (int i = 0; i < commands.length(); i++) {
            JSProxyObject obj = commands.optObject(i);
            if (obj == null) continue;
            String action = obj.optString("action", null);
            if (MPUtils.isNull(action)) continue;
            if (action.contentEquals("moveTo")) {
                lastX = (int) (obj.optDouble("x", 0.0) * MPUtils.scale(getContext()));
                lastY = (int) (obj.optDouble("y", 0.0) * MPUtils.scale(getContext()));
                bezierPath.moveTo(lastX, lastY);
            } else if (action.contentEquals("lineTo")) {
                lastX = (int) (obj.optDouble("x", 0.0) * MPUtils.scale(getContext()));
                lastY = (int) (obj.optDouble("y", 0.0) * MPUtils.scale(getContext()));
                bezierPath.lineTo(lastX, lastY);
            } else if (action.contentEquals("quadraticBezierTo")) {
                lastX = (int) (obj.optDouble("x2", 0.0) * MPUtils.scale(getContext()));
                lastY = (int) (obj.optDouble("y2", 0.0) * MPUtils.scale(getContext()));
                bezierPath.quadTo(
                        (int)(obj.optDouble("y1", 0.0) * MPUtils.scale(getContext())),
                        (int)(obj.optDouble("x1", 0.0) * MPUtils.scale(getContext())),
                        lastX,
                        lastY
                );
            } else if (action.contentEquals("cubicTo")) {
                lastX = (int) (obj.optDouble("x3", 0.0) * MPUtils.scale(getContext()));
                lastY = (int) (obj.optDouble("y3", 0.0) * MPUtils.scale(getContext()));
                bezierPath.cubicTo(
                        (float) (obj.optDouble("x1", 0.0) * MPUtils.scale(getContext())),
                        (float) (obj.optDouble("y1", 0.0) * MPUtils.scale(getContext())),
                        (float) (obj.optDouble("x2", 0.0) * MPUtils.scale(getContext())),
                        (float) (obj.optDouble("y2", 0.0) * MPUtils.scale(getContext())),
                        lastX,
                        lastY
                );
            } else if (action.contentEquals("arcTo")) {
                RectF rectF = new RectF(
                        (float)((obj.optDouble("x", 0.0) - obj.optDouble("width", 0.0) / 2.0) * MPUtils.scale(getContext())),
                        (float)((obj.optDouble("y", 0.0) - obj.optDouble("height", 0.0) / 2.0) * MPUtils.scale(getContext())),
                        (float)((obj.optDouble("x", 0.0) + obj.optDouble("width", 0.0) / 2.0) * MPUtils.scale(getContext())),
                        (float)((obj.optDouble("y", 0.0) + obj.optDouble("height", 0.0) / 2.0) * MPUtils.scale(getContext()))
                );
                bezierPath.arcTo(
                        rectF,
                        (float)(obj.optDouble("startAngle", 0.0) * 180 / Math.PI),
                        (float)(obj.optDouble("sweepAngle", 0.0) * 180 / Math.PI)
                );
            } else if (action.contentEquals("arcToPoint")) {
                double x1 = (obj.optDouble("arcControlX", 0.0) * MPUtils.scale(getContext()));
                double y1 = (obj.optDouble("arcControlY", 0.0) * MPUtils.scale(getContext()));
                double x2 = (obj.optDouble("arcEndX", 0.0) * MPUtils.scale(getContext()));
                double y2 = (obj.optDouble("arcEndY", 0.0) * MPUtils.scale(getContext()));
                double radius = (obj.optDouble("radiusX", 0.0) * MPUtils.scale(getContext()));
                if (radius == 0.0) {
                    lastX = (int) x1;
                    lastY = (int) y1;
                    bezierPath.lineTo((int)x1, (int)y1);
                    continue;
                }
                double startX = lastX;
                double startY = lastY;
                SkDVector befored = new SkDVector();
                SkDVector afterd = new SkDVector();
                befored.set(x1 - startX, y1 - startY).normalize();
                afterd.set(x2 - x1, y2 - y1).normalize();
                double cosh = befored.dot(afterd);
                double sinh = befored.cross(afterd);
                if (!befored.isFinite() || !afterd.isFinite() || SKUtils.SkScalarNearlyZero(sinh)) {
                    lastX = (int) x1;
                    lastY = (int) y1;
                    bezierPath.lineTo((int)x1, (int)y1);
                    continue;
                }
                double dist = Math.abs(radius * (1 - cosh) / sinh);
                double xx = x1 - dist * befored.fX;
                double yy = y1 - dist * befored.fY;
                afterd.setLength(dist);
                bezierPath.lineTo((int)xx, (int)yy);
                double weight = Math.sqrt(0.5 + cosh * 0.5);
                conicTo(bezierPath, x1, y1, x1 + afterd.fX, y1 + afterd.fY, weight);
                lastX = (int)x1;
                lastY = (int)y1;
            } else if (action.contentEquals("close")) {
                bezierPath.close();
            }
        }
        return bezierPath;
    }

    void conicTo(Path bezierPath, double x1, double y1, double x2, double y2, double w) {
        if (!(w > 0)) {
            bezierPath.lineTo((int)x2, (int)y2);
        } else if (((Double)w).isInfinite()) {
            bezierPath.lineTo((int)x1, (int)y1);
            bezierPath.lineTo((int)x2, (int)y2);
        } else if (1.0 == w) {
            bezierPath.quadTo((float)x1, (float)y1, (float)x2, (float)y2);
        } else {
            bezierPath.quadTo((float)x1, (float)y1, (float)x2, (float)y2);
        }
    }

    void setPaint(JSProxyObject params, Paint paint) {
        paint.reset();
        if (params == null) {
            return;
        }
        if (!params.isNull("strokeWidth")) {
            paint.setStrokeWidth((float) (params.optDouble("strokeWidth", 0.0) * MPUtils.scale(getContext())));
        }
        if (!params.isNull("miterLimit")) {
            paint.setStrokeMiter((float) (params.optDouble("miterLimit", 0.0) * MPUtils.scale(getContext())));
        }
        String strokeCap = params.optString("strokeCap", null);
        if (!MPUtils.isNull(strokeCap)) {
            if (strokeCap.contentEquals("StrokeCap.butt")) {
                paint.setStrokeCap(Paint.Cap.BUTT);
            }
            else if (strokeCap.contentEquals("StrokeCap.round")) {
                paint.setStrokeCap(Paint.Cap.ROUND);
            }
            else if (strokeCap.contentEquals("StrokeCap.square")) {
                paint.setStrokeCap(Paint.Cap.SQUARE);
            }
        }
        String strokeJoin = params.optString("strokeJoin", null);
        if (!MPUtils.isNull(strokeJoin)) {
            if (strokeJoin.contentEquals("StrokeJoin.miter")) {
                paint.setStrokeJoin(Paint.Join.MITER);
            }
            else if (strokeJoin.contentEquals("StrokeJoin.round")) {
                paint.setStrokeJoin(Paint.Join.ROUND);
            }
            else if (strokeJoin.contentEquals("StrokeJoin.bevel")) {
                paint.setStrokeJoin(Paint.Join.BEVEL);
            }
        }
        String style = params.optString("style", null);
        String color = params.optString("color", null);
        if (!MPUtils.isNull(style) && !MPUtils.isNull(color)) {
            if (style.contentEquals("PaintingStyle.fill")) {
                paint.setStyle(Paint.Style.FILL);
                paint.setColor(MPUtils.colorFromString(color));
            }
            else {
                paint.setStyle(Paint.Style.STROKE);
                paint.setColor(MPUtils.colorFromString(color));
            }
        }
        paint.setAlpha(Math.max(0, Math.min(255, (int) (params.optDouble("alpha", 1.0) * 255.0))));
        paint.setAntiAlias(true);
    }

    @Override
    public void draw(Canvas canvas) {
        super.draw(canvas);
        canvas.clipRect(new Rect(0, 0, canvas.getWidth(), canvas.getHeight()));
        canvas.save();
//        canvas.scale(MPUtils.scale(getContext()), MPUtils.scale(getContext()));
        if (commands != null) {
            Paint paint = new Paint();
            for (int i = 0; i < commands.length(); i++) {
                JSProxyObject cmd = commands.optObject(i);
                if (cmd == null) continue;
                String action = cmd.optString("action", null);
                if (!MPUtils.isNull(action)) {
                    if (action.contentEquals("drawRect")) {
                        drawRect(cmd, canvas, paint);
                    }
                    else if (action.contentEquals("drawDRRect")) {
                        drawDRRect(cmd, canvas, paint);
                    }
                    else if (action.contentEquals("drawPath")) {
                        drawPath(cmd, canvas, paint);
                    }
                    else if (action.contentEquals("clipPath")) {
                        clipPath(cmd, canvas, paint);
                    }
                    else if (action.contentEquals("drawColor")) {
                        drawColor(cmd, canvas, paint);
                    }
                    else if (action.contentEquals("drawImage")) {
                        drawImage(cmd, canvas, paint);
                    }
                    else if (action.contentEquals("drawImageRect")) {
                        drawImageRect(cmd, canvas, paint);
                    }
                    else if (action.contentEquals("save")) {
                        canvas.save();
                    }
                    else if (action.contentEquals("restore")) {
                        canvas.restore();
                    }
                    else if (action.contentEquals("rotate")) {
                        canvas.rotate((float) (cmd.optDouble("radians", 0.0) * 180.0 / Math.PI));
                    }
                    else if (action.contentEquals("scale")) {
                        canvas.scale(
                                (float)cmd.optDouble("sx", 1.0),
                                (float)cmd.optDouble("sy", 1.0));
                    }
                    else if (action.contentEquals("translate")) {
                        canvas.translate(
                                (int)(cmd.optDouble("dx", 0.0) * MPUtils.scale(getContext())),
                                (int)(cmd.optDouble("dy", 0.0) * MPUtils.scale(getContext()))
                        );
                    }
                    else if (action.contentEquals("transform")) {
                        Matrix matrix = new Matrix();
                        float a = (float) cmd.optDouble("a");
                        float b = (float) cmd.optDouble("b");
                        float c = (float) cmd.optDouble("c");
                        float d = (float) cmd.optDouble("d");
                        float tx = (float) (cmd.optDouble("tx") * MPUtils.scale(getContext()));
                        float ty = (float) (cmd.optDouble("ty") * MPUtils.scale(getContext()));
                        final float[] values = { a, c, tx, b, d, ty, 0.0f, 0.0f, 1.0f };
                        matrix.setValues(values);
                        canvas.concat(matrix);
                    }
                    else if (action.contentEquals("skew")) {
                        canvas.skew(
                                (float)cmd.optDouble("sx", 1.0),
                                (float)cmd.optDouble("sy", 1.0)
                        );
                    }
                }
            }
        }
        canvas.restore();
    }
}

class SkDVector {

    double fX;
    double fY;

    SkDVector set(double x, double y) {
        fX = x;
        fY = y;
        return this;
    }

    double cross(SkDVector a) {
        return fX * a.fY - fY * a.fX;
    }

    double dot(SkDVector a) {
        return fX * a.fX + fY * a.fY;
    }

    double length() {
        return Math.sqrt(lengthSquared());
    }

    double lengthSquared() {
        return fX * fX + fY * fY;
    }

    SkDVector normalize() {
        double inverseLength = (1 / this.length());
        fX *= inverseLength;
        fY *= inverseLength;
        return this;
    }

    void setLength(double v) {
        fX *= v;
        fY *= v;
    }

    boolean isFinite() {
        return !((Double)fX).isInfinite() && !((Double)fY).isInfinite();
    }

}

class SKUtils {

    static boolean SkScalarNearlyZero(double value) {
        return Math.abs(value) < 0.01;
    }

}