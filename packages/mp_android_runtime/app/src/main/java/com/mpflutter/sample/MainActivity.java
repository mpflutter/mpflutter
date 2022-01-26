package com.mpflutter.sample;

import androidx.appcompat.app.AppCompatActivity;

import android.os.Bundle;
import android.os.Handler;
import android.widget.FrameLayout;

import com.mpflutter.runtime.MPActivity;
import com.mpflutter.runtime.MPEngine;
import com.mpflutter.runtime.MPPage;

import java.io.IOException;
import java.io.InputStream;
import java.util.HashMap;

public class MainActivity extends MPActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        MPEngine engine = new MPEngine(this);
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
}