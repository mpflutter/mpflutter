package com.mpflutter.sample;

import androidx.appcompat.app.AppCompatActivity;

import android.os.Bundle;

import com.mpflutter.runtime.MPEngine;

public class MainActivity extends AppCompatActivity {

    MPEngine engine;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        engine = new MPEngine();
        engine.start();
        setContentView(R.layout.activity_main);
    }
}