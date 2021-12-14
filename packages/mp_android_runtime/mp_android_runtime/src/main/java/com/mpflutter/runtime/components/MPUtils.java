package com.mpflutter.runtime.components;

import android.content.Context;
import android.graphics.Color;

public class MPUtils {

    public static float scale(Context context) {
        float scale = context.getResources().getDisplayMetrics().density;
        return Math.round(scale);
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

}
