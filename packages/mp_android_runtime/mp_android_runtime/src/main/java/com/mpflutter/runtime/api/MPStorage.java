package com.mpflutter.runtime.api;

import android.content.Context;
import android.content.SharedPreferences;

import com.mpflutter.runtime.MPEngine;
import com.quickjs.JSArray;
import com.quickjs.JSContext;
import com.quickjs.JSFunction;
import com.quickjs.JSObject;
import com.quickjs.JavaCallback;

public class MPStorage {

    static public void setupWithJSContext(MPEngine engine, JSContext context, JSObject selfObject) {
        JSObject wx = context.getObject("wx");
        if (wx != null) {
            wx.set("removeStorageSync", new JSFunction(context, new JavaCallback() {
                @Override
                public Object invoke(JSObject receiver, JSArray args) {
                    if (args.length() < 1) return null;
                    String key = args.getString(0);
                    if (key != null) {
                        SharedPreferences sharedPreferences = engine.provider.dataProvider.createSharedPreferences();
                        sharedPreferences.edit().remove(key).apply();
                    }
                    return null;
                }
            }));
            wx.set("getStorageSync", new JSFunction(context, new JavaCallback() {
                @Override
                public Object invoke(JSObject receiver, JSArray args) {
                    if (args.length() < 1) return null;
                    String key = args.getString(0);
                    if (key != null) {
                        SharedPreferences sharedPreferences = engine.provider.dataProvider.createSharedPreferences();
                        return sharedPreferences.getString(key, null);
                    }
                    return null;
                }
            }));
            wx.set("setStorageSync", new JSFunction(context, new JavaCallback() {
                @Override
                public Object invoke(JSObject receiver, JSArray args) {
                    if (args.length() < 2) return null;
                    String key = args.getString(0);
                    Object value = args.get(1);
                    if (key != null) {
                        SharedPreferences sharedPreferences = engine.provider.dataProvider.createSharedPreferences();
                        if (value instanceof String) {
                            sharedPreferences.edit().putString(key, (String) value).apply();
                        }
                        else if (value instanceof Boolean) {
                            sharedPreferences.edit().putBoolean(key, (Boolean) value).apply();
                        }
                        else if (value instanceof Float) {
                            sharedPreferences.edit().putFloat(key, (Float) value).apply();
                        }
                        else if (value instanceof Integer) {
                            sharedPreferences.edit().putInt(key, (Integer) value).apply();
                        }
                        else if (value instanceof Long) {
                            sharedPreferences.edit().putLong(key, (Long) value).apply();
                        }
                    }
                    return null;
                }
            }));
            wx.set("getStorageInfoSync", new JSFunction(context, new JavaCallback() {
                @Override
                public Object invoke(JSObject receiver, JSArray args) {
                    SharedPreferences sharedPreferences = engine.provider.dataProvider.createSharedPreferences();
                    Object[] keys = sharedPreferences.getAll().keySet().toArray();
                    JSArray result = new JSArray(receiver.getContext());
                    for (int i = 0; i < keys.length; i++) {
                        Object element = keys[i];
                        if (element instanceof String) {
                            result.push((String) element);
                        }
                    }
                    JSObject info = new JSObject(receiver.getContext());
                    info.set("keys", result);
                    return info;
                }
            }));
        }
    }
}
