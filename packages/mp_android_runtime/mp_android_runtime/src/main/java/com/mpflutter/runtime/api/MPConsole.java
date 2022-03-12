package com.mpflutter.runtime.api;

import android.util.Log;

import com.eclipsesource.v8.JavaCallback;
import com.eclipsesource.v8.V8;
import com.eclipsesource.v8.V8Array;
import com.eclipsesource.v8.V8Object;
import com.mpflutter.runtime.MPRuntime;

public class MPConsole {

    static public void setupWithJSContext(V8 context) {
        V8Object jsConsole = new V8Object(context);
        jsConsole.registerJavaMethod(new JavaCallback() {
            @Override
            public Object invoke(V8Object v8Object, V8Array v8Array) {
                printConsole(Log.VERBOSE, v8Array);
                return null;
            }
        }, "log");
        jsConsole.registerJavaMethod(new JavaCallback() {
            @Override
            public Object invoke(V8Object v8Object, V8Array v8Array) {
                printConsole(Log.ERROR, v8Array);
                return null;
            }
        }, "error");
        jsConsole.registerJavaMethod(new JavaCallback() {
            @Override
            public Object invoke(V8Object v8Object, V8Array v8Array) {
                printConsole(Log.INFO, v8Array);
                return null;
            }
        }, "info");
        jsConsole.registerJavaMethod(new JavaCallback() {
            @Override
            public Object invoke(V8Object v8Object, V8Array v8Array) {
                printConsole(Log.VERBOSE, v8Array);
                return null;
            }
        }, "warn");
        jsConsole.registerJavaMethod(new JavaCallback() {
            @Override
            public Object invoke(V8Object v8Object, V8Array v8Array) {
                printConsole(Log.DEBUG, v8Array);
                return null;
            }
        }, "debug");
        context.add("console", jsConsole);
    }

    static void printConsole(int priority, V8Array args) {
        for (int i = 0; i < args.length(); i++) {
            int type = args.getType(i);
            switch (type) {
                case V8.DOUBLE:
                    Log.println(priority, MPRuntime.TAG, String.valueOf(args.getDouble(i)));
                    break;
                case V8.STRING:
                    Log.println(priority, MPRuntime.TAG, args.getString(i));
                    break;
                case V8.INTEGER:
                    Log.println(priority, MPRuntime.TAG, String.valueOf(args.getInteger(i)));
                    break;
                case V8.BOOLEAN:
                    Log.println(priority, MPRuntime.TAG, String.valueOf(args.getBoolean(i)));
                    break;
                case V8.UNDEFINED:
                    Log.println(priority, MPRuntime.TAG, "undefined");
                    break;
                case V8.V8_FUNCTION:
                    Log.println(priority, MPRuntime.TAG, "[JSFunction]");
                    break;
                case V8.V8_ARRAY:
                    Log.println(priority, MPRuntime.TAG, "[JSArray]");
                    break;
                case V8.V8_OBJECT:
                    Log.println(priority, MPRuntime.TAG, "[V8Object]");
                    break;
                case V8.NULL:
                    Log.println(priority, MPRuntime.TAG, "[JSNull]");
                    break;
            }
        }
    }

}
