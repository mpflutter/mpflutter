package com.mpflutter.sample;

import androidx.appcompat.app.AppCompatActivity;

import android.os.Bundle;
import android.os.Handler;
import android.widget.FrameLayout;

import com.mpflutter.runtime.MPEngine;
import com.mpflutter.runtime.MPPage;

import java.util.HashMap;

public class MainActivity extends AppCompatActivity {

    MPEngine engine;
    FrameLayout rootView;
    MPPage mpPage;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        engine = new MPEngine(this);
        engine.initWithDebuggerServerAddr("10.0.2.2:9898");
        engine.start();
        rootView = new FrameLayout(this);
        mpPage = new MPPage(rootView, engine, "/", new HashMap());
        setContentView(rootView);
    }
}