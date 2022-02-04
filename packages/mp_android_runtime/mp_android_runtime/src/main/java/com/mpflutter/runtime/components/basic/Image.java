package com.mpflutter.runtime.components.basic;

import android.content.Context;
import android.util.Base64;
import android.view.View;

import androidx.annotation.NonNull;

import com.mpflutter.runtime.components.MPComponentView;
import com.mpflutter.runtime.jsproxy.JSProxyArray;
import com.mpflutter.runtime.jsproxy.JSProxyObject;

public class Image extends MPComponentView {

    View contentView;

    public Image(@NonNull Context context) {
        super(context);
    }

    @Override
    public void attached() {
        super.attached();
        contentView = engine.provider.imageProvider.createImageView(getContext());
        addContentView(contentView);
    }

    @Override
    public void setChildren(JSProxyArray children) { }

    @Override
    public void setAttributes(JSProxyObject attributes) {
        super.setAttributes(attributes);
        String src = attributes.optString("src", null);
        String base64 = attributes.optString("base64", null);
        String assetName = attributes.optString("assetName", null);
        if (src != null && src != "null") {
            engine.provider.imageProvider.loadImageWithURLString(src, contentView);
        }
        else if (base64 != null && base64 != "null") {
            engine.provider.imageProvider.loadImageWithURLString("data:image/png;base64," + base64, contentView);
        }
        else if (assetName != null && assetName != "null") {
            if (engine.debugger != null) {
                String assetUrl = "http://" + engine.debugger.serverAddr + "/assets/" + assetName;
                engine.provider.imageProvider.loadImageWithURLString(assetUrl, contentView);
            }
            else if (engine.mpkReader != null) {
                byte[] data = engine.mpkReader.dataWithFilePath(assetName);
                if (data != null) {
                    String dataUri = "data:image;base64," + Base64.encodeToString(data, Base64.NO_WRAP);
                    engine.provider.imageProvider.loadImageWithURLString(dataUri, contentView);
                }
                else {
                    engine.provider.imageProvider.loadImageWithAssetName(assetName, contentView);
                }
            }
            else {
                engine.provider.imageProvider.loadImageWithAssetName(assetName, contentView);
            }
        }
        else {
            engine.provider.imageProvider.loadImageWithURLString("", contentView);
        }
        String fit = attributes.optString("fit", null);
        engine.provider.imageProvider.setFit(fit, contentView);
    }
}
