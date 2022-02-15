package com.mpflutter.runtime;

import android.content.Context;
import android.content.Intent;

import java.util.Map;

public class MPApplet {

    public static MPApplet createAppletWithEngine(MPEngine engine, String initialRoute, Map initialParams) {
        MPApplet applet = new MPApplet();
        applet.engine = engine;
        applet.initialRoute = initialRoute;
        applet.initialParams = initialParams;
        engine.initialRoute = initialRoute;
        engine.initialParams = initialParams;
        return applet;
    }

    MPEngine engine;
    String initialRoute;
    Map initialParams;

    MPApplet() {}

    public void startActivity(Context context) {
        Intent intent = new Intent(engine.context, MPActivity.class);
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        intent.putExtra("engineId", engine.hashCode());
        intent.putExtra("routeId", 0);
        intent.putExtra("isFirstPage", true);
        context.startActivity(intent);
    }

}
