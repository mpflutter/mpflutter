package com.mpflutter.sample;

import android.app.Application;
import android.content.Context;

import com.mpflutter.runtime.MPApplet;
import com.mpflutter.runtime.MPEngine;
import com.mpflutter.runtime.platform.MPPluginRegister;

import java.io.IOException;
import java.io.InputStream;
import java.util.HashMap;

public class MainApplication extends Application {

    MPApplet applet;

    @Override
    public void onCreate() {
        super.onCreate();
        MPPluginRegister.registerChannel("com.mpflutter.templateMethodChannel", MPTemplateMethodChannel.class);
        MPPluginRegister.registerChannel("com.mpflutter.templateEventChannel", MPTemplateEventChannel.class);
        MPPluginRegister.registerPlatformView("com.mpflutter.templateFooView", TemplateFooView.class);
    }

    public void startApplet(Context context) {
        MPEngine engine = new MPEngine(this);
//        engine.initWithDebuggerServerAddr("127.0.0.1:9898");
        try {
            InputStream mpkInputStream = getAssets().open("app.mpk");
            engine.initWithMpkData(mpkInputStream);
            mpkInputStream.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
        applet = MPApplet.createAppletWithEngine(engine, "/", new HashMap());
        applet.startActivity(context);
        engine.start();
    }
}
