package com.mpflutter.runtime;

import android.content.Context;
import android.content.Intent;
import android.view.ViewGroup;
import android.widget.FrameLayout;

import java.util.HashMap;
import java.util.Map;

public class MPCardlet {

    public static MPCardlet createCardletWithEngine(MPEngine engine, String initialRoute, Map initialParams) {
        MPCardlet cardlet = new MPCardlet();
        cardlet.engine = engine;
        cardlet.initialRoute = initialRoute;
        cardlet.initialParams = initialParams;
        engine.initialRoute = initialRoute;
        engine.initialParams = initialParams;
        return cardlet;
    }

    MPEngine engine;
    String initialRoute;
    Map initialParams;
    FrameLayout rootView;
    MPPage mpPage;

    MPCardlet() {}

    public void attachToView(ViewGroup view) {
        if (rootView == null) {
            rootView = new FrameLayout(view.getContext());
            mpPage = new MPPage(rootView, engine, initialRoute != null ? initialRoute : "/", initialParams != null ? initialParams : new HashMap());
        }
        view.addView(rootView, new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
    }
}
