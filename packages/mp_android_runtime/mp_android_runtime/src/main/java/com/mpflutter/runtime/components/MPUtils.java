package com.mpflutter.runtime.components;

import android.content.Context;
import android.graphics.Color;
import android.graphics.Path;
import android.graphics.RectF;
import android.util.Size;
import android.util.SizeF;

import com.mpflutter.runtime.jsproxy.JSProxyObject;

import java.util.Calendar;
import java.util.GregorianCalendar;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class MPUtils {

    private static Integer scale;

    public static float scale(Context context) {
        if (MPUtils.scale != null) {
            return MPUtils.scale;
        }
        float scale = context.getResources().getDisplayMetrics().density;
        MPUtils.scale = Math.round(scale);
        return MPUtils.scale;
    }

    public static int px2dp(double pxValue, Context context) {
        return (int) Math.round(pxValue / scale(context));
    }

    public static int dp2px(double dpValue, Context context) {
        return (int) Math.round(dpValue * scale(context));
    }

    public static int colorFromString(String value) {
        if (value == null) return 0;
        long longValue = Long.parseLong(value);
        return (int)longValue;
    }

    public static SizeF sizeFromMPElement(JSProxyObject element) {
        if (element == null) {
            return new SizeF(0, 0);
        }
        double w = 0.0, h = 0.0;
        JSProxyObject constraints = element.optObject("constraints");
        if (constraints != null &&
                constraints.has("w") &&
                constraints.has("h")) {
            w = constraints.optDouble("w", 0.0);
            h = constraints.optDouble("h", 0.0);
        }
        else if (element.optArray("children") != null &&
                element.optArray("children").length() == 1) {
            return sizeFromMPElement(element.optArray("children").optObject(0));
        }
        return new SizeF((float) w, (float)h);
    }

    public static double[] sliverPaddingFromMPElement(JSProxyObject element) {
        if (element == null) {
            return new double[4];
        }
        if (element.optString("name", "").contentEquals("padding") &&
                element.optObject("attributes") != null &&
                !element.optObject("attributes").has("padding") &&
                element.optObject("attributes").optString("sliver", "0").contentEquals("1")) {
            return edgeInsetsFromString(element.optObject("attributes").optString("padding", null));
        }
        else if (element.optArray("children") != null &&
                element.optArray("children").length() == 1) {
            return sliverPaddingFromMPElement(element.optArray("children").optObject(0));
        }
        return new double[4];
    }

    public static double[] edgeInsetsFromString(String value) {
        double[] values = new double[4];
        if (value.startsWith("EdgeInsets.all(")) {
            String trimmedValue = value.replace("EdgeInsets.all(", "").replace(")", "");
            try {
                double v = Double.parseDouble(trimmedValue);
                values[0] = values[1] = values[2] = values[3] = v;
            } catch (Throwable e) {}
        }
        else if (value.startsWith("EdgeInsets(")) {
            String trimmedValue = value.replace("EdgeInsets(", "").replace(")", "");
            String[] parts = trimmedValue.split(",");
            if (parts.length == 4) {
                values[0] = Double.parseDouble(parts[1]);
                values[1] = Double.parseDouble(parts[0]);
                values[2] = Double.parseDouble(parts[3]);
                values[3] = Double.parseDouble(parts[2]);
            }
        }
        return values;
    }

    // tl,bl,br,tr
    public static double[] cornerRadiusFromString(String value) {
        double[] values = new double[4];
        if (value.startsWith("BorderRadius.circular(")) {
            String trimmedValue = value.replace("BorderRadius.circular(", "").replace(")", "");
            try {
                double v = Double.parseDouble(trimmedValue);
                values[0] = values[1] = values[2] = values[3] = v;
            } catch (Throwable e) {}
        }
        else if (value.startsWith("BorderRadius.all(")) {
            String trimmedValue = value.replace("BorderRadius.all(", "").replace(")", "");
            try {
                double v = Double.parseDouble(trimmedValue);
                values[0] = values[1] = values[2] = values[3] = v;
            } catch (Throwable e) {}
        }
        else if (value.startsWith("BorderRadius.only(")) {
            String trimmedValue = value.replaceAll("BorderRadius.only\\(", "").replaceAll("\\)", "").replaceAll("Radius.circular\\(", "");
            values[0] = doubleFromRegularFirstObject("topLeft: ([0-9|.]+)", trimmedValue);
            values[1] = doubleFromRegularFirstObject("bottomLeft: ([0-9|.]+)", trimmedValue);
            values[2] = doubleFromRegularFirstObject("bottomRight: ([0-9|.]+)", trimmedValue);
            values[3] = doubleFromRegularFirstObject("topRight: ([0-9|.]+)", trimmedValue);
        }
        return values;
    }

    static double doubleFromRegularFirstObject(String pattern, String value) {
        Pattern p = Pattern.compile(pattern);
        Matcher matcher = p.matcher(value);
        if (matcher.find()) {
            if (matcher.groupCount() >= 1) {
                try {
                    return Double.parseDouble(matcher.group(1));
                } catch (Throwable e) {
                    return 0.0;
                }
            }
        }
        return 0.0;
    }

    static public void drawRRectWithPath(Path path, double[] values, Size size) {
        float tl = (float)values[0];
        float bl = (float)values[1];
        float br = (float)values[2];
        float tr = (float)values[3];
        path.moveTo(tl,0);
        path.lineTo(size.getWidth() - tr, 0);
        if (tr > 0) {
            path.arcTo(new RectF(size.getWidth() - tr * 2, 0, size.getWidth(), tr * 2), -90, 90);
        }
        path.lineTo(size.getWidth(), size.getHeight() - br);
        if (br > 0) {
            path.arcTo(new RectF(size.getWidth() - br * 2, size.getHeight() - br * 2, size.getWidth(), size.getHeight()), 0, 90);
        }
        path.lineTo(bl, size.getHeight());
        if (bl > 0) {
            path.arcTo(new RectF(0.0f, size.getHeight() - bl * 2, bl * 2, size.getHeight()), 90, 90);
        }
        path.lineTo(0, tl);
        if (tl > 0) {
            path.arcTo(new RectF(0.0f, 0.0f, tl * 2, tl * 2), 180, 90);
        }
        path.close();
    }

    static public long timestampFromString(String value) {
        if (value == null) return 0;
        String[] components = value.split("-");
        if (components.length == 3) {
            Calendar calendar = new GregorianCalendar();
            calendar.set(Integer.parseInt(components[0]), Integer.parseInt(components[1]) - 1, Integer.parseInt(components[2]));
            return calendar.getTimeInMillis();
        }
        return 0;
    }

    static public boolean isNull(String value) {
        if (value == null) return true;
        if (value.contentEquals("null")) return true;
        return false;
    }

}
