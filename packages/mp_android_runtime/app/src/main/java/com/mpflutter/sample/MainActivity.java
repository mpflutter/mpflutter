package com.mpflutter.sample;

import android.os.Bundle;

import com.mpflutter.runtime.MPActivity;
import com.mpflutter.runtime.MPEngine;
import com.mpflutter.runtime.platform.MPPluginRegister;

public class MainActivity extends MPActivity {

    MPEngine engine;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        installPlugins();
        MPEngine engine = new MPEngine(this);
        this.engine = engine;
        engine.initWithDebuggerServerAddr("127.0.0.1:9898");
//        try {
//            InputStream mpkInputStream = getAssets().open("app.mpk");
//            engine.initWithMpkData(mpkInputStream);
//            mpkInputStream.close();
//        } catch (IOException e) {
//            e.printStackTrace();
//        }
        engine.start();
        initializeWithEngine(engine);
        super.onCreate(savedInstanceState);
    }

    void installPlugins() {
        MPPluginRegister.registerChannel("com.mpflutter.templateMethodChannel", MPTemplateMethodChannel.class);
        MPPluginRegister.registerChannel("com.mpflutter.templateEventChannel", MPTemplateEventChannel.class);
        MPPluginRegister.registerPlatformView("com.mpflutter.templateFooView", TemplateFooView.class);
    }

}