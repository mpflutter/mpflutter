package com.mpflutter.sample;

import android.os.Handler;
import android.os.Looper;

import com.mpflutter.runtime.platform.MPEventChannel;
import com.mpflutter.runtime.platform.MPEventChannelEventSink;

import java.util.Date;
import java.util.Timer;
import java.util.TimerTask;

public class MPTemplateEventChannel extends MPEventChannel {

    Timer timer;

    @Override
    public void onListen(Object params, MPEventChannelEventSink eventSink) {
        timer = new Timer();
        timer.schedule(new TimerTask() {
            @Override
            public void run() {
                new Handler(Looper.getMainLooper()).post(new Runnable() {
                    @Override
                    public void run() {
                        eventSink.onData(new Date().toString());
                    }
                });
            }
        }, 1000, 1000);
    }

    @Override
    public void onCancel(Object params) {
        timer.cancel();
        timer = null;
    }
}
