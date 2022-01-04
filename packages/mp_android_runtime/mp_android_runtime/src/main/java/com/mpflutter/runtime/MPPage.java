package com.mpflutter.runtime;

import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import android.util.Size;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;

import com.mpflutter.runtime.components.MPComponentView;
import com.mpflutter.runtime.components.MPUtils;
import com.mpflutter.runtime.components.basic.Overlay;
import com.mpflutter.runtime.components.mpkit.MPScaffold;
import com.mpflutter.runtime.jsproxy.JSProxyArray;
import com.mpflutter.runtime.jsproxy.JSProxyObject;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;
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
    private List<MPComponentView> overlaysView = new ArrayList();

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
                    return;
                }
                MPPage.this.requestRoute(new MPRouteResponse() {
                    @Override
                    public void onResponse(int viewId) {
                        MPPage.this.viewId = viewId;
                        MPPage.this.engine.managedViews.put(viewId, MPPage.this);
                        if (MPPage.this.engine.managedViewsQueueMessage.containsKey(viewId)) {
                            List<JSProxyObject> queue = MPPage.this.engine.managedViewsQueueMessage.get(viewId);
                            for (int i = 0; i < queue.size(); i++) {
                                didReceivedFrameData(queue.get(i));
                            }
                            MPPage.this.engine.managedViewsQueueMessage.remove(viewId);
                        }
                    }
                });
            }
        }, 300);
    }

    void requestRoute(MPRouteResponse response) {
        engine.router.requestRoute(initialRoute, initialParams, false, new Size(MPUtils.px2dp(rootView.getWidth(), rootView.getContext()), MPUtils.px2dp(rootView.getHeight(), rootView.getContext())), response);
    }

    @Override
    public void didReceivedFrameData(JSProxyObject message) {
        JSProxyObject scaffold = message.optObject("scaffold");
        MPComponentView scaffoldView = engine.componentFactory.create(scaffold);
        if (scaffoldView instanceof MPScaffold) {
            ((MPScaffold) scaffoldView).rootViewContext = rootView.getContext();
            ((MPScaffold) scaffoldView).resetNavigationItems();
        }
        if (scaffoldView != null && scaffoldView.getParent() != rootView) {
            if (scaffoldView.getParent() != null) {
                ((ViewGroup)scaffoldView.getParent()).removeView(scaffoldView);
            }
            rootView.addView(scaffoldView, new FrameLayout.LayoutParams(FrameLayout.LayoutParams.WRAP_CONTENT, FrameLayout.LayoutParams.WRAP_CONTENT));
        }
        this.scaffoldView = scaffoldView;
        JSProxyArray overlays = message.optArray("overlays");
        if (overlays != null) {
            setOverlays(overlays);
        }
    }

    void setOverlays(JSProxyArray overlays) {
        if (!overlaysView.isEmpty()) {
            for (int i = 0; i < overlaysView.size(); i++) {
                View view = overlaysView.get(i);
                if (view.getParent() != null) {
                    ((ViewGroup)view.getParent()).removeView(view);
                }
            }
            overlaysView.clear();
        }
        for (int i = 0; i < overlays.length(); i++) {
            JSProxyObject obj = overlays.optObject(i);
            if (obj == null) continue;
            MPComponentView overlayView = engine.componentFactory.create(obj);
            if (overlayView != null) {
                overlaysView.add(overlayView);
                rootView.addView(overlayView);
            }
        }
    }

    public boolean shouldInterceptBackPressed() {
        if(!overlaysView.isEmpty()) {
            View view = overlaysView.get(0);
            if (view instanceof Overlay) {
                return ((Overlay) view).onBackgroundTap;
            }
        }
        return false;
    }

    public void handleBackPressed() {
        if(!overlaysView.isEmpty()) {
            View view = overlaysView.get(0);
            if (view instanceof Overlay) {
                ((Overlay) view).onBackPressed();
            }
        }
    }
}
