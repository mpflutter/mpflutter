package com.mpflutter.runtime.provider;

import android.app.Activity;
import android.content.Context;
import android.content.DialogInterface;
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

import com.google.android.material.bottomsheet.BottomSheetDialog;
import com.mpflutter.runtime.MPEngine;
import com.mpflutter.runtime.components.MPUtils;
import com.mpflutter.runtime.components.mpkit.MPIcon;
import com.mpflutter.runtime.jsproxy.JSProxyObject;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

public class MPDialogProvider {
    public MPDialogProvider(Context context) { }
    public void showAlert(Activity currentActivity, String message, MPIOSDialogProviderAlertCompletionBlock completionBlock) {}
    public void showConfirm(Activity currentActivity, String message, MPIOSDialogProviderConfirmCompletionBlock completionBlock) {}
    public void showPrompt(Activity currentActivity, String message, String defaultValue, MPIOSDialogProviderPromptCompletionBlock completionBlock) {}
    public void showActionSheet(Activity currentActivity, List<String> items, MPIOSDialogProviderActionSheetCompletionBlock completionBlock) {}
    public void showToast(Activity currentActivity, String icon, String title, int duration) {}
    public void hideToast(Activity currentActivity) {}

    static public class DefaultProvider extends MPDialogProvider {

        public DefaultProvider(Context context) {
            super(context);
        }

        @Override
        public void showAlert(Activity currentActivity, String message, MPIOSDialogProviderAlertCompletionBlock completionBlock) {
            AlertDialog.Builder builder = new AlertDialog.Builder(currentActivity);
            builder.setMessage(message);
            builder.setPositiveButton("好的", new DialogInterface.OnClickListener() {
                @Override
                public void onClick(DialogInterface dialogInterface, int i) {
                    completionBlock.onComplete();
                }
            });
            builder.setOnCancelListener(new DialogInterface.OnCancelListener() {
                @Override
                public void onCancel(DialogInterface dialogInterface) {
                    completionBlock.onComplete();
                }
            });
            builder.create().show();
        }

        @Override
        public void showConfirm(Activity currentActivity, String message, MPIOSDialogProviderConfirmCompletionBlock completionBlock) {
            AlertDialog.Builder builder = new AlertDialog.Builder(currentActivity);
            builder.setMessage(message);
            builder.setPositiveButton("确认", new DialogInterface.OnClickListener() {
                @Override
                public void onClick(DialogInterface dialogInterface, int i) {
                    completionBlock.onComplete(true);
                }
            });
            builder.setNegativeButton("取消", new DialogInterface.OnClickListener() {
                @Override
                public void onClick(DialogInterface dialogInterface, int i) {
                    completionBlock.onComplete(false);
                }
            });
            builder.setOnCancelListener(new DialogInterface.OnCancelListener() {
                @Override
                public void onCancel(DialogInterface dialogInterface) {
                    completionBlock.onComplete(false);
                }
            });
            builder.create().show();
        }

        @Override
        public void showPrompt(Activity currentActivity, String message, String defaultValue, MPIOSDialogProviderPromptCompletionBlock completionBlock) {
            AlertDialog.Builder builder = new AlertDialog.Builder(currentActivity);
            builder.setMessage(message);
            EditText editText = new EditText(currentActivity);
            editText.setSingleLine();
            editText.setPadding(MPUtils.dp2px(20, currentActivity), MPUtils.dp2px(12, currentActivity), MPUtils.dp2px(20, currentActivity), MPUtils.dp2px(12, currentActivity));
            if (defaultValue != null && defaultValue != "null") {
                editText.setText(defaultValue);
            }
            builder.setView(editText);
            builder.setPositiveButton("确认", new DialogInterface.OnClickListener() {
                @Override
                public void onClick(DialogInterface dialogInterface, int i) {
                    completionBlock.onComplete(editText.getText().toString());
                }
            });
            builder.setNegativeButton("取消", new DialogInterface.OnClickListener() {
                @Override
                public void onClick(DialogInterface dialogInterface, int i) {
                    completionBlock.onComplete(null);
                }
            });
            builder.setOnCancelListener(new DialogInterface.OnCancelListener() {
                @Override
                public void onCancel(DialogInterface dialogInterface) {
                    completionBlock.onComplete(null);
                }
            });
            builder.create().show();
        }

        @Override
        public void showActionSheet(Activity currentActivity, List<String> items, MPIOSDialogProviderActionSheetCompletionBlock completionBlock) {
            BottomSheetDialog bottomSheetDialog = new BottomSheetDialog(currentActivity);
            LinearLayout linearLayout = new LinearLayout(currentActivity);
            linearLayout.setOrientation(LinearLayout.VERTICAL);
            List<View> textViews = new ArrayList();
            for (int i = 0; i < items.size(); i++) {
                if (i > 0) {
                    View divider = new View(currentActivity);
                    divider.setBackgroundColor(0xffe0e0e0);
                    linearLayout.addView(divider, new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, 1));
                }
                String item = items.get(i);
                if (item != null) {
                    AppCompatButton textView = new AppCompatButton(currentActivity);
                    textView.setBackgroundColor(Color.TRANSPARENT);
                    textView.setText(item);
                    textView.setHeight(MPUtils.dp2px(48, currentActivity));
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
                    completionBlock.onComplete(-1);
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
                        completionBlock.onComplete(finalI);
                    }
                });
            }
        }

        static AlertDialog activeHUD;

        @Override
        public void showToast(Activity currentActivity, String icon, String title, int duration) {
            if (activeHUD != null) {
                activeHUD.hide();
                activeHUD = null;
            }
            if (MPUtils.isNull(title)) {
                title = null;
            }
            AlertDialog dialog = null;
            if (!MPUtils.isNull(icon) && (icon.contentEquals("ToastIcon.loading") || icon.contentEquals("ToastIcon.success") || icon.contentEquals("ToastIcon.error"))) {
                dialog = MPToast.buildHUD(icon, title, currentActivity);
                if (dialog != null) {
                    dialog.setCancelable(false);
                    dialog.show();
                    dialog.getWindow().setLayout(MPUtils.dp2px(120, currentActivity), MPUtils.dp2px(120, currentActivity));
                    dialog.getWindow().setBackgroundDrawable(new ColorDrawable(Color.TRANSPARENT));
                    activeHUD = dialog;
                }
            }
            else {
                Toast.makeText(currentActivity, title, Toast.LENGTH_SHORT).show();
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

        @Override
        public void hideToast(Activity currentActivity) {
            if (activeHUD != null) {
                activeHUD.hide();
                activeHUD = null;
            }
        }
    }
}

class MPToast {

    static AlertDialog buildHUD(String icon, String message, Activity currentActivity) {
        Context context = currentActivity;
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
                    attributes.putOpt("iconUrl", "https://dist.mpflutter.com/material-design-icons/src/action/check_circle/materialicons/24px.svg");
                }
                else if (icon.contentEquals("ToastIcon.error")) {
                    attributes.putOpt("iconUrl", "https://dist.mpflutter.com/material-design-icons/src/alert/error/materialicons/24px.svg");
                }
            } catch (JSONException e) {
                e.printStackTrace();
            }
            successIcon.setAttributes(new JSProxyObject(attributes));
            JSONObject constraints = new JSONObject();
            try {
                constraints.putOpt("x", 0);
                constraints.putOpt("y", 0);
                constraints.putOpt("w", 44);
                constraints.putOpt("h", 44);
            } catch (JSONException e) {
                e.printStackTrace();
            }
            successIcon.setConstraints(new JSProxyObject(constraints));
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
