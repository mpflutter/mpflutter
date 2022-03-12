package com.mpflutter.runtime.components.basic;

import android.content.Context;

import com.mpflutter.runtime.MPEngine;
import com.mpflutter.runtime.components.MPUtils;
import com.mpflutter.runtime.jsproxy.JSProxyArray;
import com.mpflutter.runtime.jsproxy.JSProxyObject;
import com.mpflutter.runtime.provider.MPIOSDialogProviderActionSheetCompletionBlock;
import com.mpflutter.runtime.provider.MPIOSDialogProviderAlertCompletionBlock;
import com.mpflutter.runtime.provider.MPIOSDialogProviderConfirmCompletionBlock;
import com.mpflutter.runtime.provider.MPIOSDialogProviderPromptCompletionBlock;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

public class WebDialogs {

    static public void didReceivedWebDialogsMessage(JSProxyObject message, MPEngine engine) {
        JSProxyObject params = message.optObject("params");
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

    static void alert(JSProxyObject message, MPEngine engine) {
        String callbackId = message.optString("id", null);
        String alertMessage = message.optObject("params").optString("message", null);
        if (MPUtils.isNull(callbackId)) {
            return;
        }
        if (MPUtils.isNull(alertMessage)) {
            return;
        }
        if (engine.router.activeActivity == null) {
            return;
        }
        engine.provider.dialogProvider.showAlert(engine.router.activeActivity, alertMessage, new MPIOSDialogProviderAlertCompletionBlock() {
            @Override
            public void onComplete() {
                engine.sendMessage(new HashMap(){{
                    put("type", "action");
                    put("message", new HashMap(){{
                        put("event", "callback");
                        put("id", callbackId);
                    }});
                }});
            }
        });
    }

    static void confirm(JSProxyObject message, MPEngine engine) {
        String callbackId = message.optString("id", null);
        String alertMessage = message.optObject("params").optString("message", null);
        if (MPUtils.isNull(callbackId)) {
            return;
        }
        if (MPUtils.isNull(alertMessage)) {
            return;
        }
        if (engine.router.activeActivity == null) {
            return;
        }
        engine.provider.dialogProvider.showConfirm(engine.router.activeActivity, alertMessage, new MPIOSDialogProviderConfirmCompletionBlock() {
            @Override
            public void onComplete(boolean result) {
                engine.sendMessage(new HashMap(){{
                    put("type", "action");
                    put("message", new HashMap(){{
                        put("event", "callback");
                        put("id", callbackId);
                        put("data", result);
                    }});
                }});
            }
        });
    }

    static void prompt(JSProxyObject message, MPEngine engine) {
        String callbackId = message.optString("id", null);
        String alertMessage = message.optObject("params").optString("message", null);
        String defaultValue = message.optObject("params").optString("defaultValue", null);
        if (MPUtils.isNull(callbackId)) {
            return;
        }
        if (MPUtils.isNull(alertMessage)) {
            return;
        }
        if (engine.router.activeActivity == null) {
            return;
        }
        engine.provider.dialogProvider.showPrompt(engine.router.activeActivity, alertMessage, defaultValue, new MPIOSDialogProviderPromptCompletionBlock() {
            @Override
            public void onComplete(String result) {
                engine.sendMessage(new HashMap(){{
                    put("type", "action");
                    put("message", new HashMap(){{
                        put("event", "callback");
                        put("id", callbackId);
                        put("data", result);
                    }});
                }});
            }
        });
    }

    static void actionSheet(JSProxyObject message, MPEngine engine) {
        Context context = engine.router.activeActivity;
        String callbackId = message.optString("id", null);
        JSProxyArray items = message.optObject("params").optArray("items");
        if (MPUtils.isNull(callbackId)) {
            return;
        }
        if (items == null) {
            return;
        }
        if (context == null) {
            return;
        }
        List<String> stringItems = new ArrayList();
        for (int i = 0; i < items.length(); i++) {
            stringItems.add(items.optString(i, ""));
        }
        engine.provider.dialogProvider.showActionSheet(engine.router.activeActivity, stringItems, new MPIOSDialogProviderActionSheetCompletionBlock() {
            @Override
            public void onComplete(int result) {
                engine.sendMessage(new HashMap(){{
                    put("type", "action");
                    put("message", new HashMap(){{
                        put("event", "callback");
                        put("id", callbackId);
                        put("data", result < 0 ? null : result);
                    }});
                }});
            }
        });
    }

    static void showToast(JSProxyObject message, MPEngine engine) {
        JSProxyObject params = message.optObject("params");
        if (params == null) {
            return;
        }
        engine.provider.dialogProvider.showToast(engine.router.activeActivity, params.optString("icon", null), params.optString("title", null), params.optInt("duration", -1));
    }

    static void hideToast(JSProxyObject message, MPEngine engine) {
        engine.provider.dialogProvider.hideToast(engine.router.activeActivity);
    }

}

