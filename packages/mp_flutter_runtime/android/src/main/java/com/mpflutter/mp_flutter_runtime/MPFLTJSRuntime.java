package com.mpflutter.mp_flutter_runtime;

import android.os.Looper;
import android.util.Log;

import androidx.annotation.NonNull;

import com.mpflutter.mp_flutter_runtime.api.MPTimer;
import com.quickjs.JSArray;
import com.quickjs.JSContext;
import com.quickjs.JSFunction;
import com.quickjs.JSObject;
import com.quickjs.JSValue;
import com.quickjs.JavaCallback;
import com.quickjs.QuickJS;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class MPFLTJSRuntime implements FlutterPlugin, MethodChannel.MethodCallHandler, EventChannel.StreamHandler {

    private MethodChannel channel;
    private EventChannel eventChannel;
    private EventChannel.EventSink eventSink;
    private QuickJS quickJS;
    private Map<String, JSContext> contextRefs = new HashMap();

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "com.mpflutter.mp_flutter_runtime.js_context");
        channel.setMethodCallHandler(this);
        eventChannel = new EventChannel(flutterPluginBinding.getBinaryMessenger(), "com.mpflutter.mp_flutter_runtime.js_callback");
        eventChannel.setStreamHandler(this);
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {

    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        assert (Thread.currentThread() == Looper.getMainLooper().getThread());
        if (call.method.contentEquals("createContext")) {
            String ref = UUID.randomUUID().toString();
            quickJS = QuickJS.createRuntime();
            JSContext context = quickJS.createContext();
            MPTimer.setupWithJSContext(context);
            context.set("postMessage", new JSFunction(context, new JavaCallback() {
                @Override
                public Object invoke(JSObject receiver, JSArray args) {
                    if (eventSink != null) {
                        eventSink.success(new HashMap(){{
                            put("contextRef", ref);
                            put("data", args.get(0));
                            put("type", args.get(1));
                        }});
                    }
                    return null;
                }
            }));
            contextRefs.put(ref, context);
            result.success(ref);
        }
        else if (call.method.contentEquals("releaseContext") && call.arguments instanceof String) {
            String ref = (String) call.arguments;
            JSContext context = contextRefs.get(ref);
            if (context != null) {
                context.close();
                contextRefs.remove(ref);
            }
            result.success(null);
        }
        else if (call.method.contentEquals("evaluateScript") && call.arguments instanceof Map) {
            Map options = (Map) call.arguments;
            try {
                String contextRef = (String) options.get("contextRef");
                String script = (String) options.get("script");
                JSContext context = contextRefs.get(contextRef);
                if (context != null) {
                    Object ret = context.executeScript(script, "");
                    result.success(transformJSObjectToFlutterObject(ret));
                }
                else {
                    result.error("MPJSRuntime", "context not found.", "context not found.");
                }
            } catch (Throwable e) {
                result.error("MPJSRuntime", e.toString(), e.toString());
            }
        }
        else if (call.method.contentEquals("invokeFunc") && call.arguments instanceof Map) {
            Map options = (Map) call.arguments;
            try {
                String contextRef = (String) options.get("contextRef");
                String func = (String) options.get("func");
                List args = (List) options.get("args");
                JSContext context = contextRefs.get(contextRef);
                if (context != null) {
                    JSFunction jsFunc = (JSFunction) (func.contains(".") ? context.executeScript(func, "") : context.get(func));
                    JSArray jsArgs = new JSArray(context);
                    for (int i = 0; i < args.size(); i++) {
                        Object v = transformFlutterObjectToJSObject(context, args.get(i));
                        if (v instanceof JSValue) {
                            jsArgs.push((JSValue) v);
                        }
                        else if (v instanceof String) {
                            jsArgs.push((String) v);
                        }
                        else if (v instanceof Boolean) {
                            jsArgs.push((boolean) v);
                        }
                        else if (v instanceof Integer) {
                            jsArgs.push((int) v);
                        }
                        else if (v instanceof Double) {
                            jsArgs.push((double) v);
                        }
                        else if (v instanceof Float) {
                            jsArgs.push((float) v);
                        }
                    }
                    Object ret = jsFunc.call(jsFunc, jsArgs);
                    result.success(transformJSObjectToFlutterObject(ret));
                }
                else {
                    result.error("MPJSRuntime", "context not found.", "context not found.");
                }
            } catch (Throwable e) {
                result.error("MPJSRuntime", e.toString(), e.toString());
            }
        }
        else if (call.method.contentEquals("invokeMPJSFunc") && call.arguments instanceof Map) {
            Map options = (Map) call.arguments;
            try {
                String contextRef = (String) options.get("contextRef");
                Map message = (Map) options.get("message");
                JSContext context = contextRefs.get(contextRef);
                if (context != null) {
                    JSFunction jsFunction = (JSFunction) context.executeScript("MPJS.instance.handleMessage", "");
                    JSArray args = new JSArray(context);
                    args.push((JSValue) transformFlutterObjectToJSObject(context, message));
                    args.push(new JSFunction(context, new JavaCallback() {
                        @Override
                        public Object invoke(JSObject receiver, JSArray args) {
                            result.success(transformJSObjectToFlutterObject(args.get(0)));
                            return null;
                        }
                    }));
                    args.push(new JSFunction(context, new JavaCallback() {
                        @Override
                        public Object invoke(JSObject receiver, JSArray args) {
                            result.success(transformJSObjectToFlutterObject(args.get(0)));
                            return null;
                        }
                    }));
                    jsFunction.call(null, args);
                }
                else {
                    result.error("MPJSRuntime", "context not found.", "context not found.");
                }
            } catch (Throwable e) {
                result.error("MPJSRuntime", e.toString(), e.toString());
            }
        }
        else {
            result.notImplemented();
        }
    }

    private Object transformJSObjectToFlutterObject(Object jsObject) {
        if (jsObject instanceof JSArray) {
            List list = new ArrayList();
            for (int i = 0; i < ((JSArray)jsObject).length(); i++) {
                list.add(transformJSObjectToFlutterObject(((JSArray)jsObject).get(i)));
            }
            return list;
        }
        else if (jsObject instanceof JSObject) {
            if (((JSObject) jsObject).isUndefined()) {
                return null;
            }
            Map map = new HashMap();
            String[] keys = ((JSObject) jsObject).getKeys();
            for (String key : keys) {
                Object obj = ((JSObject) jsObject).get(key);
                JSValue.TYPE type = ((JSObject) jsObject).getType(key);
                if (type == JSValue.TYPE.UNDEFINED || obj instanceof JSFunction) {
                    continue;
                }
                if (obj instanceof Number || obj instanceof String || obj instanceof Boolean) {
                    map.put(key, obj);
                } else if (obj instanceof JSArray) {
                    map.put(key, transformJSObjectToFlutterObject(obj));
                } else if (obj instanceof JSObject) {
                    map.put(key, transformJSObjectToFlutterObject(obj));
                }
            }
            return map;
        }
        else {
            return jsObject;
        }
    }

    private Object transformFlutterObjectToJSObject(JSContext context, Object jsObject) {
        if (jsObject instanceof JSObject) {
            return jsObject;
        }
        else if (jsObject instanceof Map) {
            return new JSObject(context, new JSONObject((Map) jsObject));
        }
        else if (jsObject instanceof List) {
            return new JSArray(context, new JSONArray((List)jsObject));
        }
        else {
            return jsObject;
        }
    }

    @Override
    public void onListen(Object arguments, EventChannel.EventSink events) {
        this.eventSink = events;
    }

    @Override
    public void onCancel(Object arguments) {
        this.eventChannel = null;
    }
}
