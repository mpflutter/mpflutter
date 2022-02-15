package com.mpflutter.sample;

import android.app.Activity;
import android.graphics.Color;
import android.os.Bundle;
import android.widget.FrameLayout;

import com.mpflutter.runtime.MPCardlet;
import com.mpflutter.runtime.MPEngine;

import java.util.HashMap;

public class MainActivity extends Activity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        ((MainApplication)getApplication()).startApplet(this);
        finish();
    }

//    MPCardlet cardlet;
//    FrameLayout cardView;
//
//    @Override
//    protected void onCreate(Bundle savedInstanceState) {
//        super.onCreate(savedInstanceState);
//        FrameLayout contentView = new FrameLayout(this);
//        contentView.setBackgroundColor(Color.BLACK);
//        cardView = new FrameLayout(this);
//        contentView.addView(cardView, new FrameLayout.LayoutParams(
//                (int) (300 * getResources().getDisplayMetrics().density),
//                (int) (300 * getResources().getDisplayMetrics().density)
//        ));
//        setContentView(contentView);
//        startCardlet();
//    }
//
//    void startCardlet() {
//        MPEngine engine = new MPEngine(this);
//        engine.initWithDebuggerServerAddr("127.0.0.1:9898");
//        cardlet = MPCardlet.createCardletWithEngine(engine, "/", new HashMap());
//        cardlet.attachToView(cardView);
//        engine.start();
//    }

}