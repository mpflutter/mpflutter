package com.mpflutter.runtime.api;

import android.os.Handler;

import com.quickjs.JSArray;
import com.quickjs.JSContext;
import com.quickjs.JSFunction;
import com.quickjs.JSObject;
import com.quickjs.JavaCallback;

import java.util.HashMap;
import java.util.Timer;
import java.util.TimerTask;

public class MPTimer {

    static private Timer sharedTimer = new Timer();
    static private int taskSeqId = 0;
    static private HashMap<Integer, TimerTask> timerTaskHandler = new HashMap<Integer, TimerTask>();

    static public void setupWithJSContext(JSContext context) {
        context.set("setTimeout", new JSFunction(context, new JavaCallback() {
            @Override
            public Object invoke(JSObject receiver, JSArray args) {
                if (args.length() < 2) {
                    return null;
                }
                Handler handler = new Handler();
                JSFunction callback = (JSFunction) args.getObject(0);
                int time = args.getInteger(1);
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
        }));
        context.set("clearTimeout", new JSFunction(context, new JavaCallback() {
            @Override
            public Object invoke(JSObject receiver, JSArray args) {
                if (args.length() < 1) {
                    return null;
                }
                int handler = args.getInteger(0);
                TimerTask timerTask = timerTaskHandler.get(handler);
                if (timerTask != null) {
                    timerTask.cancel();
                    timerTaskHandler.remove(handler);
                }
                return null;
            }
        }));
        context.set("setInterval", new JSFunction(context, new JavaCallback() {
            @Override
            public Object invoke(JSObject receiver, JSArray args) {
                if (args.length() < 2) {
                    return null;
                }
                Handler handler = new Handler();
                JSFunction callback = (JSFunction) args.getObject(0);
                int time = args.getInteger(1);
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
        }));
        context.set("clearInterval", new JSFunction(context, new JavaCallback() {
            @Override
            public Object invoke(JSObject receiver, JSArray args) {
                if (args.length() < 1) {
                    return null;
                }
                int handler = args.getInteger(0);
                TimerTask timerTask = timerTaskHandler.get(handler);
                if (timerTask != null) {
                    timerTask.cancel();
                    timerTaskHandler.remove(handler);
                }
                return null;
            }
        }));
        context.set("requestAnimationFrame", new JSFunction(context, new JavaCallback() {
            @Override
            public Object invoke(JSObject receiver, JSArray args) {
                if (args.length() < 1) {
                    return null;
                }
                Handler handler = new Handler();
                JSFunction callback = (JSFunction) args.getObject(0);
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
                sharedTimer.schedule(timerTask, 16);
                return currentTaskSeqId;
            }
        }));
        context.set("cancelAnimationFrame", new JSFunction(context, new JavaCallback() {
            @Override
            public Object invoke(JSObject receiver, JSArray args) {
                if (args.length() < 1) {
                    return null;
                }
                int handler = args.getInteger(0);
                TimerTask timerTask = timerTaskHandler.get(handler);
                if (timerTask != null) {
                    timerTask.cancel();
                    timerTaskHandler.remove(handler);
                }
                return null;
            }
        }));
    }

}
