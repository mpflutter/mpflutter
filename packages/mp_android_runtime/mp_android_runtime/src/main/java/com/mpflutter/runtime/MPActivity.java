package com.mpflutter.runtime;

import android.os.Bundle;
import android.widget.FrameLayout;

import androidx.appcompat.app.AppCompatActivity;

import java.util.HashMap;
import java.util.Map;

public class MPActivity extends AppCompatActivity {

    MPEngine engine;
    FrameLayout rootView;
    MPPage mpPage;
    boolean firstShowed = false;
    String initialRoute;
    Map initialParams;

    public void initializeWithEngine(MPEngine engine) {
        this.engine = engine;
    }

    public void initializeWithEngine(MPEngine engine, String initialRoute, Map initialParams) {
        this.engine = engine;
        this.initialRoute = initialRoute;
        this.initialParams = initialParams;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        getSupportActionBar().setTitle("");
        if (engine == null) {
            int engineId = getIntent().getIntExtra("engineId", -1);
            if (engineId < 0 || !MPEngine.engineStore.containsKey(engineId)) {
                return;
            }
            engine = MPEngine.engineStore.get(engineId).get();
            if (engine == null) {
                return;
            }
        }
        rootView = new FrameLayout(this);
        mpPage = new MPPage(rootView, engine, initialRoute != null ? initialRoute : "/", initialParams != null ? initialParams : new HashMap());
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

    @Override
    public void onBackPressed() {
        if (mpPage != null) {
            if (mpPage.shouldInterceptBackPressed()) {
                mpPage.handleBackPressed();
                return;
            }
        }
        super.onBackPressed();
    }
}
