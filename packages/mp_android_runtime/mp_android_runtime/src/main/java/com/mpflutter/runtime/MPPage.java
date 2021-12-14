package com.mpflutter.runtime;

import android.os.Handler;
import android.os.Looper;
import android.util.Size;
import android.view.ViewGroup;
import android.widget.FrameLayout;

import com.mpflutter.runtime.components.MPComponentView;
import com.mpflutter.runtime.components.MPUtils;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.Map;

public class MPPage implements MPDataReceiver {

    private int viewId;

    public int getViewId() {
        return viewId;
    }

    private FrameLayout rootView;
    private MPEngine engine;
    private String initialRoute;
    private Map initialParams;
    private MPComponentView scaffoldView;

    public MPPage(FrameLayout rootView, MPEngine engine, String initialRoute, Map initialParams) {
        this.rootView = rootView;
        this.engine = engine;
        this.initialRoute = initialRoute;
        this.initialParams = initialParams;
        loopCheckRootViewAttached();
    }

    void loopCheckRootViewAttached() {
        new Handler(Looper.getMainLooper()).postDelayed(new Runnable() {
            @Override
            public void run() {
                if (!rootView.isAttachedToWindow() || rootView.getWidth() <= 0.0) {
                    loopCheckRootViewAttached();
                }
                MPPage.this.requestRoute(new MPRouteResponse() {
                    @Override
                    public void onResponse(int viewId) {
                        MPPage.this.viewId = viewId;
                        MPPage.this.engine.managedViews.put(viewId, MPPage.this);
                    }
                });
            }
        }, 32);
    }

    void requestRoute(MPRouteResponse response) {
        engine.router.requestRoute(initialRoute, initialParams, false, new Size(MPUtils.px2dp(rootView.getWidth(), rootView.getContext()), MPUtils.px2dp(rootView.getHeight(), rootView.getContext())), response);
    }

    @Override
    public void didReceivedFrameData(JSONObject message) throws JSONException {
        JSONObject scaffold = message.optJSONObject("scaffold");
        MPComponentView scaffoldView = engine.componentFactory.create(scaffold);
        if (scaffoldView != null && scaffoldView.getParent() != rootView) {
            if (scaffoldView.getParent() != null) {
                ((ViewGroup)scaffoldView.getParent()).removeView(scaffoldView);
            }
            rootView.addView(scaffoldView, new FrameLayout.LayoutParams(FrameLayout.LayoutParams.WRAP_CONTENT, FrameLayout.LayoutParams.WRAP_CONTENT));
        }
        this.scaffoldView = scaffoldView;
    }
}
