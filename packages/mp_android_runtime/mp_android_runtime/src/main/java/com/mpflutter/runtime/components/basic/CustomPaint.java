package com.mpflutter.runtime.components.basic;

import android.content.Context;
import android.graphics.BlendMode;
import android.graphics.Canvas;
import android.graphics.Matrix;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.PorterDuff;
import android.graphics.RectF;
import android.os.Build;

import androidx.annotation.NonNull;

import com.mpflutter.runtime.components.MPComponentView;
import com.mpflutter.runtime.components.MPUtils;

import org.json.JSONArray;
import org.json.JSONObject;

public class CustomPaint extends MPComponentView {

    JSONArray commands;

    public CustomPaint(@NonNull Context context) {
        super(context);
        setWillNotDraw(false);
    }

    @Override
    public void setAttributes(JSONObject attributes) {
        super.setAttributes(attributes);
        this.commands = attributes.optJSONArray("commands");
        invalidate();
    }

    void drawRect(JSONObject cmd, Canvas canvas, Paint paint) {
        double x = cmd.optDouble("x");
        double y = cmd.optDouble("y");
        double width = cmd.optDouble("width");
        double height = cmd.optDouble("height");
        setPaint(cmd.optJSONObject("paint"), paint);
        canvas.drawRect(
                MPUtils.dp2px(x, getContext()),
                MPUtils.dp2px(y, getContext()),
                MPUtils.dp2px(x + width, getContext()),
                MPUtils.dp2px(y + height, getContext()),
                paint);
    }

    void drawDRRect(JSONObject cmd, Canvas canvas, Paint paint) {

    }

    void drawPath(JSONObject cmd, Canvas canvas, Paint paint) {
        Path bezierPath = pathWithParams(cmd.optJSONObject("path"));
        setPaint(cmd.optJSONObject("paint"), paint);
        canvas.drawPath(bezierPath, paint);
    }

    void clipPath(JSONObject cmd, Canvas canvas, Paint paint) {
        Path bezierPath = pathWithParams(cmd.optJSONObject("path"));
        setPaint(cmd.optJSONObject("paint"), paint);
        canvas.clipPath(bezierPath);
    }

    void drawColor(JSONObject cmd, Canvas canvas, Paint paint) {
        String blendMode = cmd.optString("blendMode", null);
        String color = cmd.optString("color", null);
        if (blendMode != null && blendMode.contentEquals("BlendMode.clear")) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                canvas.drawColor(MPUtils.colorFromString(color), BlendMode.CLEAR);
            } else {
                canvas.drawColor(MPUtils.colorFromString(color), PorterDuff.Mode.CLEAR);
            }
        }
        else {
            canvas.drawColor(MPUtils.colorFromString(color));
        }
    }

    Path pathWithParams(JSONObject path) {
        Path bezierPath = new Path();
        if (path == null) {
            return bezierPath;
        }
        JSONArray commands = path.optJSONArray("commands");
        if (commands == null) {
            return bezierPath;
        }
        for (int i = 0; i < commands.length(); i++) {
            JSONObject obj = commands.optJSONObject(i);
            if (obj == null) continue;
            String action = obj.optString("action", null);
            if (MPUtils.isNull(action)) continue;
            if (action.contentEquals("moveTo")) {
                bezierPath.moveTo(
                        MPUtils.dp2px(obj.optDouble("x", 0.0), getContext()),
                        MPUtils.dp2px(obj.optDouble("y", 0.0), getContext())
                );
            } else if (action.contentEquals("lineTo")) {
                bezierPath.lineTo(
                        MPUtils.dp2px(obj.optDouble("x", 0.0), getContext()),
                        MPUtils.dp2px(obj.optDouble("y", 0.0), getContext())
                );
            } else if (action.contentEquals("quadraticBezierTo")) {
                bezierPath.quadTo(
                        MPUtils.dp2px(obj.optDouble("x1", 0.0), getContext()),
                        MPUtils.dp2px(obj.optDouble("y1", 0.0), getContext()),
                        MPUtils.dp2px(obj.optDouble("x2", 0.0), getContext()),
                        MPUtils.dp2px(obj.optDouble("y2", 0.0), getContext())
                );
            } else if (action.contentEquals("cubicTo")) {
                bezierPath.cubicTo(
                        MPUtils.dp2px(obj.optDouble("x1", 0.0), getContext()),
                        MPUtils.dp2px(obj.optDouble("y1", 0.0), getContext()),
                        MPUtils.dp2px(obj.optDouble("x2", 0.0), getContext()),
                        MPUtils.dp2px(obj.optDouble("y2", 0.0), getContext()),
                        MPUtils.dp2px(obj.optDouble("x3", 0.0), getContext()),
                        MPUtils.dp2px(obj.optDouble("y3", 0.0), getContext())
                );
            } else if (action.contentEquals("arcTo")) {
                RectF rectF = new RectF(
                        MPUtils.dp2px(obj.optDouble("x", 0.0), getContext()),
                        MPUtils.dp2px(obj.optDouble("y", 0.0), getContext()),
                        MPUtils.dp2px(obj.optDouble("x", 0.0), getContext()) + MPUtils.dp2px(obj.optDouble("width", 0.0), getContext()),
                        MPUtils.dp2px(obj.optDouble("y", 0.0), getContext()) + MPUtils.dp2px(obj.optDouble("height", 0.0), getContext())
                );
                bezierPath.addArc(
                        rectF,
                        MPUtils.dp2px(obj.optDouble("startAngle", 0.0), getContext()),
                        MPUtils.dp2px(obj.optDouble("sweepAngle", 0.0), getContext())
                );
            } else if (action.contentEquals("arcToPoint")) {
                // todo
            } else if (action.contentEquals("close")) {
                bezierPath.close();
            }
        }
        return bezierPath;
    }

    void setPaint(JSONObject params, Paint paint) {
        paint.reset();
        if (params == null) {
            return;
        }
        if (!params.isNull("strokeWidth")) {
            paint.setStrokeWidth(MPUtils.dp2px(params.optDouble("strokeWidth", 0.0), getContext()));
        }
        if (!params.isNull("miterLimit")) {
            paint.setStrokeMiter(MPUtils.dp2px(params.optDouble("miterLimit", 0.0), getContext()));
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
    }

    @Override
    public void draw(Canvas canvas) {
        super.draw(canvas);
        canvas.save();
        if (commands != null) {
            Paint paint = new Paint();
            for (int i = 0; i < commands.length(); i++) {
                JSONObject cmd = commands.optJSONObject(i);
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
                                MPUtils.dp2px(cmd.optDouble("dx", 1.0), getContext()),
                                MPUtils.dp2px(cmd.optDouble("dy", 1.0), getContext()));
                    }
                    else if (action.contentEquals("transform")) {
                        Matrix matrix = new Matrix();
                        float a = (float) cmd.optDouble("a");
                        float b = (float) cmd.optDouble("b");
                        float c = (float) cmd.optDouble("c");
                        float d = (float) cmd.optDouble("d");
                        float tx = MPUtils.dp2px(cmd.optDouble("tx"), getContext());
                        float ty = MPUtils.dp2px(cmd.optDouble("ty"), getContext());
                        final float[] values = { a, c, tx, b, d, ty, 0.0f, 0.0f, 1.0f };
                        matrix.setValues(values);
                        canvas.concat(matrix);
                    }
                    else if (action.contentEquals("skew")) {
                        canvas.skew(
                                (float)cmd.optDouble("sx", 1.0),
                                (float)cmd.optDouble("sy", 1.0));
                    }
                }
            }
        }
        canvas.restore();
    }
}
