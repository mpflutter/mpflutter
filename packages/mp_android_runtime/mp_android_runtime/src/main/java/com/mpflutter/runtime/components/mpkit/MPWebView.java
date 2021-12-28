package com.mpflutter.runtime.components.mpkit;

import android.content.Context;
import android.webkit.WebChromeClient;
import android.webkit.WebView;
import android.webkit.WebViewClient;

import androidx.annotation.NonNull;

import com.mpflutter.runtime.components.MPUtils;
import com.mpflutter.runtime.jsproxy.JSProxyArray;
import com.mpflutter.runtime.jsproxy.JSProxyObject;

import org.json.JSONArray;
import org.json.JSONObject;

public class MPWebView extends MPPlatformView {

    WebView contentView;
    boolean firstSetted = false;

    public MPWebView(@NonNull Context context) {
        super(context);
        contentView = new WebView(context);
        contentView.setWebChromeClient(new WebChromeClient());
        contentView.setWebViewClient(new WebViewClient());
        contentView.getSettings().setJavaScriptEnabled(true);
        addContentView(contentView);
    }

    @Override
    public void setChildren(JSProxyArray children) { }

    @Override
    public void setAttributes(JSProxyObject attributes) {
        super.setAttributes(attributes);
        String url = attributes.optString("url", null);
        if (!MPUtils.isNull(url) && !firstSetted) {
            firstSetted = true;
            contentView.loadUrl(url);
        }
    }

    @Override
    public void onMethodCall(String method, Object params, MPPlatformViewCallback callback) {
        if (method.contentEquals("reload")) {
            contentView.reload();
        }
        else if (method.contentEquals("loadUrl") && params instanceof JSProxyObject) {
            String url = ((JSProxyObject) params).optString("url", null);
            if (!MPUtils.isNull(url)) {
                contentView.loadUrl(url);
            }
        }
    }
}
