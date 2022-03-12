package com.mpflutter.mp_flutter_runtime.api;

import android.os.Handler;

import com.eclipsesource.v8.JavaCallback;
import com.eclipsesource.v8.V8;
import com.eclipsesource.v8.V8Array;
import com.eclipsesource.v8.V8Function;
import com.eclipsesource.v8.V8Object;

import java.util.HashMap;
import java.util.Timer;
import java.util.TimerTask;

public class MPTimer {

    static private Timer sharedTimer = new Timer();
    static private int taskSeqId = 0;
    static private HashMap<Integer, TimerTask> timerTaskHandler = new HashMap<Integer, TimerTask>();

    static public void setupWithJSContext(V8 context) {
        context.registerJavaMethod(new JavaCallback() {
            @Override
            public Object invoke(V8Object v8Object, V8Array v8Array) {
                if (v8Array.length() < 2) {
                    return null;
                }
                Handler handler = new Handler();
                V8Function callback = (V8Function) v8Array.getObject(0);
                int time = v8Array.getInteger(1);
                taskSeqId++;
                int currentTaskSeqId = taskSeqId;
                TimerTask timerTask = new TimerTask() {
                    @Override
                    public void run() {
                        handler.post(new Runnable() {
                            @Override
                            public void run() {
                                timerTaskHandler.remove(currentTaskSeqId);
                                try {
                                    callback.call(null, null);
                                } catch (Throwable e) {
                                    e.printStackTrace();
                                }
                            }
                        });
                    }
                };
                timerTaskHandler.put(currentTaskSeqId, timerTask);
                sharedTimer.schedule(timerTask, time);
                return currentTaskSeqId;
            }
        }, "setTimeout");
        context.registerJavaMethod(new JavaCallback() {
            @Override
            public Object invoke(V8Object v8Object, V8Array v8Array) {
                if (v8Array.length() < 1) {
                    return null;
                }
                int handler = v8Array.getInteger(0);
                TimerTask timerTask = timerTaskHandler.get(handler);
                if (timerTask != null) {
                    timerTask.cancel();
                    timerTaskHandler.remove(handler);
                }
                return null;
            }
        }, "clearTimeout");
        context.registerJavaMethod(new JavaCallback() {
            @Override
            public Object invoke(V8Object v8Object, V8Array v8Array) {
                if (v8Array.length() < 2) {
                    return null;
                }
                Handler handler = new Handler();
                V8Function callback = (V8Function) v8Array.getObject(0);
                int time = v8Array.getInteger(1);
                taskSeqId++;
                int currentTaskSeqId = taskSeqId;
                TimerTask timerTask = new TimerTask() {
                    @Override
                    public void run() {
                        handler.post(new Runnable() {
                            @Override
                            public void run() {
                                timerTaskHandler.remove(currentTaskSeqId);
                                try {
                                    callback.call(null, null);
                                } catch (Throwable e) {
                                    e.printStackTrace();
                                }
                            }
                        });
                    }
                };
                timerTaskHandler.put(currentTaskSeqId, timerTask);
                sharedTimer.schedule(timerTask, time, time);
                return currentTaskSeqId;
            }
        }, "setInterval");
        context.registerJavaMethod(new JavaCallback() {
            @Override
            public Object invoke(V8Object v8Object, V8Array v8Array) {
                if (v8Array.length() < 1) {
                    return null;
                }
                int handler = v8Array.getInteger(0);
                TimerTask timerTask = timerTaskHandler.get(handler);
                if (timerTask != null) {
                    timerTask.cancel();
                    timerTaskHandler.remove(handler);
                }
                return null;
            }
        }, "clearInterval");
        context.registerJavaMethod(new JavaCallback() {
            @Override
            public Object invoke(V8Object v8Object, V8Array v8Array) {
                if (v8Array.length() < 1) {
                    return null;
                }
                Handler handler = new Handler();
                V8Function callback = (V8Function) v8Array.getObject(0);
                taskSeqId++;
                int currentTaskSeqId = taskSeqId;
                TimerTask timerTask = new TimerTask() {
                    @Override
                    public void run() {
                        handler.post(new Runnable() {
                            @Override
                            public void run() {
                                timerTaskHandler.remove(currentTaskSeqId);
                                try {
                                    long time = System.currentTimeMillis();
                                    V8Array args = new V8Array(context);
                                    args.push(time);
                                    callback.call(null, args);
                                } catch (Throwable e) {
                                    e.printStackTrace();
                                }
                            }
                        });
                    }
                };
                timerTaskHandler.put(currentTaskSeqId, timerTask);
                sharedTimer.schedule(timerTask, 16);
                return currentTaskSeqId;
            }
        }, "requestAnimationFrame");
        context.registerJavaMethod(new JavaCallback() {
            @Override
            public Object invoke(V8Object v8Object, V8Array v8Array) {
                if (v8Array.length() < 1) {
                    return null;
                }
                int handler = v8Array.getInteger(0);
                TimerTask timerTask = timerTaskHandler.get(handler);
                if (timerTask != null) {
                    timerTask.cancel();
                    timerTaskHandler.remove(handler);
                }
                return null;
            }
        }, "cancelAnimationFrame");
    }

}
