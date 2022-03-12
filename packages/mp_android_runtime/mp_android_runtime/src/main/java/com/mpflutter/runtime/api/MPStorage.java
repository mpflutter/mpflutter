package com.mpflutter.runtime.api;

import android.content.SharedPreferences;

import com.eclipsesource.v8.JavaCallback;
import com.eclipsesource.v8.V8;
import com.eclipsesource.v8.V8Array;
import com.eclipsesource.v8.V8Object;
import com.mpflutter.runtime.MPEngine;

public class MPStorage {

    static public void setupWithJSContext(MPEngine engine, V8 context) {
        V8Object wx = context.getObject("wx");
        if (wx != null) {
            wx.registerJavaMethod(new JavaCallback() {
                @Override
                public Object invoke(V8Object v8Object, V8Array v8Array) {
                    if (v8Array.length() < 1) return null;
                    String key = v8Array.getString(0);
                    if (key != null) {
                        SharedPreferences sharedPreferences = engine.provider.dataProvider.createSharedPreferences();
                        sharedPreferences.edit().remove(key).apply();
                    }
                    return null;
                }
            }, "removeStorageSync");
            wx.registerJavaMethod(new JavaCallback() {
                @Override
                public Object invoke(V8Object v8Object, V8Array v8Array) {
                    if (v8Array.length() < 1) return null;
                    String key = v8Array.getString(0);
                    if (key != null) {
                        SharedPreferences sharedPreferences = engine.provider.dataProvider.createSharedPreferences();
                        return sharedPreferences.getString(key, null);
                    }
                    return null;
                }
            }, "getStorageSync");
            wx.registerJavaMethod(new JavaCallback() {
                @Override
                public Object invoke(V8Object v8Object, V8Array v8Array) {
                    if (v8Array.length() < 2) return null;
                    String key = v8Array.getString(0);
                    Object value = v8Array.get(1);
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
            }, "setStorageSync");
            wx.registerJavaMethod(new JavaCallback() {
                @Override
                public Object invoke(V8Object v8Object, V8Array v8Array) {
                    SharedPreferences sharedPreferences = engine.provider.dataProvider.createSharedPreferences();
                    Object[] keys = sharedPreferences.getAll().keySet().toArray();
                    V8Array result = new V8Array(v8Object.getRuntime());
                    for (int i = 0; i < keys.length; i++) {
                        Object element = keys[i];
                        if (element instanceof String) {
                            result.push((String) element);
                        }
                    }
                    V8Object info = new V8Object(v8Object.getRuntime());
                    info.add("keys", result);
                    return info;
                }
            }, "getStorageInfoSync");
        }
    }
}
