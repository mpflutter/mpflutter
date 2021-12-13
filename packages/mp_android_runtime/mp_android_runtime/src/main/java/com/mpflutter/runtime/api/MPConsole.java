package com.mpflutter.runtime.api;

import android.util.Log;

import com.quickjs.JSArray;
import com.quickjs.JSContext;
import com.mpflutter.runtime.MPRuntime;
import com.quickjs.JSFunction;
import com.quickjs.JSObject;
import com.quickjs.JSValue;
import com.quickjs.JavaCallback;

public class MPConsole {

    static public void setupWithJSContext(JSContext context) {
        JSObject jsConsole = new JSObject(context);
        jsConsole.set("log", new JSFunction(context, new JavaCallback() {
            @Override
            public Object invoke(JSObject receiver, JSArray args) {
                printConsole(Log.VERBOSE, args);
                return null;
            }
        }));
        jsConsole.set("error", new JSFunction(context, new JavaCallback() {
            @Override
            public Object invoke(JSObject receiver, JSArray args) {
                printConsole(Log.ERROR, args);
                return null;
            }
        }));
        jsConsole.set("info", new JSFunction(context, new JavaCallback() {
            @Override
            public Object invoke(JSObject receiver, JSArray args) {
                printConsole(Log.INFO, args);
                return null;
            }
        }));
        jsConsole.set("warn", new JSFunction(context, new JavaCallback() {
            @Override
            public Object invoke(JSObject receiver, JSArray args) {
                printConsole(Log.WARN, args);
                return null;
            }
        }));
        jsConsole.set("debug", new JSFunction(context, new JavaCallback() {
            @Override
            public Object invoke(JSObject receiver, JSArray args) {
                printConsole(Log.DEBUG, args);
                return null;
            }
        }));
        context.set("console", jsConsole);
    }

    static void printConsole(int priority, JSArray args) {
        for (int i = 0; i < args.length(); i++) {
            JSValue.TYPE type = args.getType(i);
            switch (type) {
                case DOUBLE:
                    Log.println(priority, MPRuntime.TAG, String.valueOf(args.getDouble(i)));
                    break;
                case STRING:
                    Log.println(priority, MPRuntime.TAG, args.getString(i));
                    break;
                case INTEGER:
                    Log.println(priority, MPRuntime.TAG, String.valueOf(args.getInteger(i)));
                    break;
                case BOOLEAN:
                    Log.println(priority, MPRuntime.TAG, String.valueOf(args.getBoolean(i)));
                    break;
                case UNDEFINED:
                    Log.println(priority, MPRuntime.TAG, "undefined");
                    break;
                case JS_FUNCTION:
                    Log.println(priority, MPRuntime.TAG, "[JSFunction]");
                    break;
                case JS_ARRAY:
                    Log.println(priority, MPRuntime.TAG, "[JSArray]");
                    break;
                case JS_OBJECT:
                    Log.println(priority, MPRuntime.TAG, "[JSObject]");
                    break;
                case UNKNOWN:
                    Log.println(priority, MPRuntime.TAG, "[JSUnknown]");
                    break;
                case NULL:
                    Log.println(priority, MPRuntime.TAG, "[JSNull]");
                    break;
            }
        }
    }

}
