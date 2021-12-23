package com.mpflutter.runtime.components.basic;

import android.content.Context;
import android.content.DialogInterface;
import android.content.res.ColorStateList;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Path;
import android.graphics.RectF;
import android.graphics.drawable.ColorDrawable;
import android.os.Handler;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.TextView;
import android.widget.Toast;

import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.widget.AppCompatButton;
import androidx.core.view.ViewCompat;

import com.google.android.material.bottomsheet.BottomSheetDialog;
import com.google.android.material.button.MaterialButton;
import com.mpflutter.runtime.MPEngine;
import com.mpflutter.runtime.components.MPUtils;
import com.mpflutter.runtime.components.mpkit.MPIcon;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

public class WebDialogs {

    static public void didReceivedWebDialogsMessage(JSONObject message, MPEngine engine) {
        JSONObject params = message.optJSONObject("params");
        if (params != null) {
            String dialogType = params.optString("dialogType", null);
            if (dialogType != null && dialogType != "null") {
                if (dialogType.contentEquals("alert")) {
                    alert(message, engine);
                }
                else if (dialogType.contentEquals("confirm")) {
                    confirm(message, engine);
                }
                else if (dialogType.contentEquals("prompt")) {
                    prompt(message, engine);
                }
                else if (dialogType.contentEquals("actionSheet")) {
                    actionSheet(message, engine);
                }
                else if (dialogType.contentEquals("showToast")) {
                    showToast(message, engine);
                }
                else if (dialogType.contentEquals("hideToast")) {
                    hideToast(message, engine);
                }
            }
        }
    }

    static void alert(JSONObject message, MPEngine engine) {
        String callbackId = message.optString("id", null);
        String alertMessage = message.optJSONObject("params").optString("message");
        if (MPUtils.isNull(callbackId)) {
            return;
        }
        if (MPUtils.isNull(alertMessage)) {
            return;
        }
        if (engine.router.activeActivity == null) {
            return;
        }
        AlertDialog.Builder builder = new AlertDialog.Builder(engine.router.activeActivity);
        builder.setMessage(alertMessage);
        builder.setPositiveButton("好的", new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialogInterface, int i) {
                engine.sendMessage(new HashMap(){{
                    put("type", "action");
                    put("message", new HashMap(){{
                        put("event", "callback");
                        put("id", callbackId);
                    }});
                }});
            }
        });
        builder.setOnCancelListener(new DialogInterface.OnCancelListener() {
            @Override
            public void onCancel(DialogInterface dialogInterface) {
                engine.sendMessage(new HashMap(){{
                    put("type", "action");
                    put("message", new HashMap(){{
                        put("event", "callback");
                        put("id", callbackId);
                    }});
                }});
            }
        });
        builder.create().show();
    }

    static void confirm(JSONObject message, MPEngine engine) {
        String callbackId = message.optString("id", null);
        String alertMessage = message.optJSONObject("params").optString("message");
        if (MPUtils.isNull(callbackId)) {
            return;
        }
        if (MPUtils.isNull(alertMessage)) {
            return;
        }
        if (engine.router.activeActivity == null) {
            return;
        }
        AlertDialog.Builder builder = new AlertDialog.Builder(engine.router.activeActivity);
        builder.setMessage(alertMessage);
        builder.setPositiveButton("确认", new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialogInterface, int i) {
                engine.sendMessage(new HashMap(){{
                    put("type", "action");
                    put("message", new HashMap(){{
                        put("event", "callback");
                        put("id", callbackId);
                        put("data", true);
                    }});
                }});
            }
        });
        builder.setNegativeButton("取消", new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialogInterface, int i) {
                engine.sendMessage(new HashMap(){{
                    put("type", "action");
                    put("message", new HashMap(){{
                        put("event", "callback");
                        put("id", callbackId);
                        put("data", false);
                    }});
                }});
            }
        });
        builder.setOnCancelListener(new DialogInterface.OnCancelListener() {
            @Override
            public void onCancel(DialogInterface dialogInterface) {
                engine.sendMessage(new HashMap(){{
                    put("type", "action");
                    put("message", new HashMap(){{
                        put("event", "callback");
                        put("id", callbackId);
                        put("data", null);
                    }});
                }});
            }
        });
        builder.create().show();
    }

    static void prompt(JSONObject message, MPEngine engine) {
        String callbackId = message.optString("id", null);
        String alertMessage = message.optJSONObject("params").optString("message");
        String defaultValue = message.optJSONObject("params").optString("defaultValue");
        if (MPUtils.isNull(callbackId)) {
            return;
        }
        if (MPUtils.isNull(alertMessage)) {
            return;
        }
        if (engine.router.activeActivity == null) {
            return;
        }
        AlertDialog.Builder builder = new AlertDialog.Builder(engine.router.activeActivity);
        builder.setMessage(alertMessage);
        EditText editText = new EditText(engine.router.activeActivity);
        editText.setSingleLine();
        editText.setPadding(MPUtils.dp2px(20, engine.router.activeActivity), MPUtils.dp2px(12, engine.router.activeActivity), MPUtils.dp2px(20, engine.router.activeActivity), MPUtils.dp2px(12, engine.router.activeActivity));
        if (defaultValue != null && defaultValue != "null") {
            editText.setText(defaultValue);
        }
        builder.setView(editText);
        builder.setPositiveButton("确认", new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialogInterface, int i) {
                engine.sendMessage(new HashMap(){{
                    put("type", "action");
                    put("message", new HashMap(){{
                        put("event", "callback");
                        put("id", callbackId);
                        put("data", editText.getText().toString());
                    }});
                }});
            }
        });
        builder.setNegativeButton("取消", new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialogInterface, int i) {
                engine.sendMessage(new HashMap(){{
                    put("type", "action");
                    put("message", new HashMap(){{
                        put("event", "callback");
                        put("id", callbackId);
                        put("data", null);
                    }});
                }});
            }
        });
        builder.setOnCancelListener(new DialogInterface.OnCancelListener() {
            @Override
            public void onCancel(DialogInterface dialogInterface) {
                engine.sendMessage(new HashMap(){{
                    put("type", "action");
                    put("message", new HashMap(){{
                        put("event", "callback");
                        put("id", callbackId);
                        put("data", null);
                    }});
                }});
            }
        });
        builder.create().show();
    }

    static void actionSheet(JSONObject message, MPEngine engine) {
        Context context = engine.router.activeActivity;
        String callbackId = message.optString("id", null);
        JSONArray items = message.optJSONObject("params").optJSONArray("items");
        if (MPUtils.isNull(callbackId)) {
            return;
        }
        if (items == null) {
            return;
        }
        if (context == null) {
            return;
        }

        BottomSheetDialog bottomSheetDialog = new BottomSheetDialog(context);

        LinearLayout linearLayout = new LinearLayout(context);
        linearLayout.setOrientation(LinearLayout.VERTICAL);
        List<View> textViews = new ArrayList();
        for (int i = 0; i < items.length(); i++) {
            if (i > 0) {
                View divider = new View(context);
                divider.setBackgroundColor(0xffe0e0e0);
                linearLayout.addView(divider, new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, 1));
            }
            String item = items.optString(i, "");
            if (item != null) {
                AppCompatButton textView = new AppCompatButton(context);
                textView.setBackgroundColor(Color.TRANSPARENT);
                textView.setText(item);
                textView.setHeight(MPUtils.dp2px(48, context));
                textView.setTextSize(18);
                textView.setGravity(Gravity.CENTER);
                textViews.add(textView);
                linearLayout.addView(textView);
            }
        }
        bottomSheetDialog.setContentView(linearLayout);
        bottomSheetDialog.setCancelable(true);
        bottomSheetDialog.setOnCancelListener(new DialogInterface.OnCancelListener() {
            @Override
            public void onCancel(DialogInterface dialogInterface) {
                engine.sendMessage(new HashMap(){{
                    put("type", "action");
                    put("message", new HashMap(){{
                        put("event", "callback");
                        put("id", callbackId);
                        put("data", null);
                    }});
                }});
            }
        });
        bottomSheetDialog.show();
        for (int i = 0; i < textViews.size(); i++) {
            View textView = textViews.get(i);
            int finalI = i;
            textView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    bottomSheetDialog.hide();
                    engine.sendMessage(new HashMap(){{
                        put("type", "action");
                        put("message", new HashMap(){{
                            put("event", "callback");
                            put("id", callbackId);
                            put("data", finalI);
                        }});
                    }});
                }
            });
        }
    }

    static AlertDialog activeHUD;

    static void showToast(JSONObject message, MPEngine engine) {
        JSONObject params = message.optJSONObject("params");
        if (params == null) {
            return;
        }
        if (activeHUD != null) {
            activeHUD.hide();
            activeHUD = null;
        }
        String icon = params.optString("icon", null);
        String title = params.optString("title", null);
        int duration = params.optInt("duration", -1);
        if (MPUtils.isNull(title)) {
            title = null;
        }
        AlertDialog dialog = null;
        if (!MPUtils.isNull(icon) && (icon.contentEquals("ToastIcon.loading") || icon.contentEquals("ToastIcon.success") || icon.contentEquals("ToastIcon.error"))) {
            dialog = MPToast.buildHUD(icon, title, engine);
            if (dialog != null) {
                dialog.show();
                dialog.getWindow().setLayout(MPUtils.dp2px(120, engine.context), MPUtils.dp2px(120, engine.context));
                dialog.getWindow().setBackgroundDrawable(new ColorDrawable(Color.TRANSPARENT));
                activeHUD = dialog;
            }
        }
        else {
            Toast.makeText(engine.context, title, Toast.LENGTH_SHORT).show();
        }
        if (duration >= 0) {
            AlertDialog finalDialog = dialog;
            new Handler().postDelayed(new Runnable() {
                @Override
                public void run() {
                    if (finalDialog != null && finalDialog.isShowing()) {
                        finalDialog.hide();
                        if (activeHUD == finalDialog) {
                            activeHUD = null;
                        }
                    }
                }
            }, duration);
        }
    }

    static void hideToast(JSONObject message, MPEngine engine) {
        if (activeHUD != null) {
            activeHUD.hide();
            activeHUD = null;
        }
    }

}

class MPToast {

    static AlertDialog buildHUD(String icon, String message, MPEngine engine) {
        Context context = engine.router.activeActivity;
        if (context == null) {
            return null;
        }
        AlertDialog.Builder builder = new AlertDialog.Builder(context);
        LinearLayout linearLayout = new LinearLayout(context) {
            @Override
            public void draw(Canvas canvas) {
                canvas.save();
                Path p = new Path();
                p.addRoundRect(new RectF(0, 0, canvas.getWidth(), getHeight()), MPUtils.dp2px(12, context), MPUtils.dp2px(12, context), Path.Direction.CCW);
                canvas.clipPath(p);
                super.draw(canvas);
                canvas.restore();
            }
        };
        linearLayout.setMinimumHeight(MPUtils.dp2px(120, context));
        linearLayout.setBackgroundColor(Color.WHITE);
        linearLayout.setOrientation(LinearLayout.VERTICAL);
        linearLayout.setGravity(Gravity.CENTER);
        if (icon.contentEquals("ToastIcon.loading")) {
            ProgressBar progressBar = new ProgressBar(context);
            progressBar.setIndeterminate(true);
            linearLayout.addView(progressBar);
        }
        else if (icon.contentEquals("ToastIcon.success") || icon.contentEquals("ToastIcon.error")) {
            MPIcon successIcon = new MPIcon(context);
            JSONObject attributes = new JSONObject();
            try {
                if (icon.contentEquals("ToastIcon.success")) {
                    attributes.putOpt("iconUrl", "https://cdn.jsdelivr.net/gh/google/material-design-icons@master/src/action/check_circle/materialicons/24px.svg");
                }
                else if (icon.contentEquals("ToastIcon.error")) {
                    attributes.putOpt("iconUrl", "https://cdn.jsdelivr.net/gh/google/material-design-icons@master/src/alert/error/materialicons/24px.svg");
                }
            } catch (JSONException e) {
                e.printStackTrace();
            }
            successIcon.setAttributes(attributes);
            JSONObject constraints = new JSONObject();
            try {
                constraints.putOpt("x", 0);
                constraints.putOpt("y", 0);
                constraints.putOpt("w", 44);
                constraints.putOpt("h", 44);
            } catch (JSONException e) {
                e.printStackTrace();
            }
            successIcon.setConstraints(constraints);
            successIcon.setX(MPUtils.dp2px((120 - 44) / 2, context));
            linearLayout.addView(successIcon);
        }
        if (message != null && message != "null") {
            linearLayout.addView(new View(context), 0, MPUtils.dp2px(10, context));
            TextView msgText = new TextView(context);
            msgText.setText(message);
            msgText.setTextSize(18);
            msgText.setGravity(Gravity.CENTER);
            linearLayout.addView(msgText);
        }
        builder.setView(linearLayout);
        AlertDialog dialog = builder.create();
        return dialog;
    }

}
