package com.mpflutter.runtime;

import android.app.Activity;
import android.os.Bundle;
import android.widget.FrameLayout;

import androidx.appcompat.app.AppCompatActivity;

import java.util.HashMap;

public class MPActivity extends AppCompatActivity {

    MPEngine engine;
    FrameLayout rootView;
    MPPage mpPage;
    boolean firstShowed = false;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        int engineId = getIntent().getIntExtra("engineId", -1);
        int routeId = getIntent().getIntExtra("routeId", -1);
        if (engineId < 0 || !MPEngine.engineStore.containsKey(engineId)) {
            return;
        }
        engine = MPEngine.engineStore.get(engineId).get();
        if (engine == null) {
            return;
        }
        rootView = new FrameLayout(this);
        mpPage = new MPPage(rootView, engine, "/", new HashMap());
        setContentView(rootView);
    }

    @Override
    protected void onResume() {
        super.onResume();
        if (engine == null) return;
        if (firstShowed) {
            engine.router.triggerPop(mpPage.getViewId());
        } else {
            firstShowed = true;
        }
        engine.router.activeActivity = this;
    }

    @Override
    public void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        if (engine == null) return;
        engine.router.dispose(mpPage.getViewId());
    }
}
