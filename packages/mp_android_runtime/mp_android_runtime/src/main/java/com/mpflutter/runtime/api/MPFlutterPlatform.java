package com.mpflutter.runtime.api;

import android.content.ClipData;
import android.content.ClipDescription;
import android.content.ClipboardManager;
import android.content.Context;

import com.mpflutter.runtime.jsproxy.JSProxyObject;
import com.mpflutter.runtime.platform.MPMethodChannel;
import com.mpflutter.runtime.platform.MPMethodChannelCallback;

import java.util.HashMap;

public class MPFlutterPlatform extends MPMethodChannel {

    @Override
    public void onMethodCall(String method, Object params, MPMethodChannelCallback result) {
        if (method.contentEquals("Clipboard.setData")) {
            if (params instanceof JSProxyObject) {
                ClipboardManager clipboardManager = (ClipboardManager) engine.context.getSystemService(Context.CLIPBOARD_SERVICE);
                clipboardManager.setPrimaryClip(ClipData.newPlainText(ClipDescription.MIMETYPE_TEXT_PLAIN, ((JSProxyObject) params).optString("text", "")));
            }
        }
        else if (method.contentEquals("Clipboard.getData")) {
            ClipboardManager clipboardManager = (ClipboardManager) engine.context.getSystemService(Context.CLIPBOARD_SERVICE);
            ClipData data = clipboardManager.getPrimaryClip();
            if (data != null && data.getItemCount() > 0 && data.getItemAt(0).getText() != null) {
                result.success(new HashMap(){{
                    put("text", data.getItemAt(0).getText().toString());
                }});
            }
            else {
                result.success(new HashMap(){{
                    put("text", "");
                }});
            }
        }
        else {
            result.fail("NOT IMPLEMENTED.");
        }
    }
}
