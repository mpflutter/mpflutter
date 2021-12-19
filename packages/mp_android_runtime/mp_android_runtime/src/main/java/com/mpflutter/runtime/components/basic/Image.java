package com.mpflutter.runtime.components.basic;

import android.content.Context;

import androidx.annotation.NonNull;

import com.facebook.drawee.drawable.ScalingUtils;
import com.facebook.drawee.view.SimpleDraweeView;
import com.mpflutter.runtime.components.MPComponentView;
import com.mpflutter.runtime.components.MPUtils;

import org.json.JSONArray;
import org.json.JSONObject;

public class Image extends MPComponentView {

    SimpleDraweeView contentView;

    public Image(@NonNull Context context) {
        super(context);
        contentView = new SimpleDraweeView(context);
    }

    @Override
    public void updateLayout() {
        super.updateLayout();
        if (constraints == null) return;
        double w = constraints.optDouble("w");
        double h = constraints.optDouble("h");
        removeView(contentView);
        addView(contentView, MPUtils.dp2px(w, getContext()), MPUtils.dp2px(h, getContext()));
    }

    @Override
    public void setChildren(JSONArray children) { }

    @Override
    public void setAttributes(JSONObject attributes) {
        super.setAttributes(attributes);
        String src = attributes.optString("src", null);
        String base64 = attributes.optString("base64", null);
        String assetName = attributes.optString("assetName", null);
        if (src != null && src != "null") {
            contentView.setImageURI(src);
        }
        else if (base64 != null && base64 != "null") {
            contentView.setImageURI("data:image/png;base64," + base64);
        }
        else if (assetName != null && assetName != "null") {
            if (engine.debugger != null) {
                String assetUrl = "http://" + engine.debugger.serverAddr + "/assets/" + assetName;
                contentView.setImageURI(assetUrl);
            }
//            else {
//                if (sImageLoader != NULL) {
//                    sImageLoader(self.contentView, assetName);
//                }
//            }
        }
        else {
            contentView.setImageURI("");
        }
        String fit = attributes.optString("fit", null);
        if (fit != null) {
            if (fit.contentEquals("BoxFit.contain")) {
                contentView.getHierarchy().setActualImageScaleType(ScalingUtils.ScaleType.FIT_CENTER);
            }
            else if (fit.contentEquals("BoxFit.cover")) {
                contentView.getHierarchy().setActualImageScaleType(ScalingUtils.ScaleType.CENTER_CROP);
            }
            else if (fit.contentEquals("BoxFit.fill")) {
                contentView.getHierarchy().setActualImageScaleType(ScalingUtils.ScaleType.FIT_XY);
            }
            else {
                contentView.getHierarchy().setActualImageScaleType(ScalingUtils.ScaleType.FIT_CENTER);
            }
        }
        else {
            contentView.getHierarchy().setActualImageScaleType(ScalingUtils.ScaleType.FIT_CENTER);
        }
    }
}
