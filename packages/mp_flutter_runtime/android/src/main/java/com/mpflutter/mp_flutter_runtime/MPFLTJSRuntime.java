package com.mpflutter.mp_flutter_runtime;

import android.os.Looper;

import androidx.annotation.NonNull;

import com.eclipsesource.v8.JavaCallback;
import com.eclipsesource.v8.V8;
import com.eclipsesource.v8.V8Array;
import com.eclipsesource.v8.V8Function;
import com.eclipsesource.v8.V8Object;
import com.eclipsesource.v8.V8Value;
import com.mpflutter.mp_flutter_runtime.api.MPTimer;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.UUID;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class MPFLTJSRuntime implements FlutterPlugin, MethodChannel.MethodCallHandler, EventChannel.StreamHandler {

    private MethodChannel channel;
    private EventChannel eventChannel;
    private EventChannel.EventSink eventSink;
    private Map<String, V8> contextRefs = new HashMap();

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
            V8 context = V8.createV8Runtime("globalThis");
            MPTimer.setupWithJSContext(context);
            context.registerJavaMethod(new JavaCallback() {
                @Override
                public Object invoke(V8Object v8Object, V8Array v8Array) {
                    if (eventSink != null) {
                        eventSink.success(new HashMap(){{
                            put("contextRef", ref);
                            put("data", v8Array.get(0));
                            put("type", v8Array.get(1));
                        }});
                    }
                    return null;
                }
            }, "postMessage");
            contextRefs.put(ref, context);
            result.success(ref);
        }
        else if (call.method.contentEquals("releaseContext") && call.arguments instanceof String) {
            String ref = (String) call.arguments;
            V8 context = contextRefs.get(ref);
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
                V8 context = contextRefs.get(contextRef);
                if (context != null) {
                    Object ret = context.executeScript(script, "");
                    result.success(transformV8ObjectToFlutterObject(ret));
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
                V8 context = contextRefs.get(contextRef);
                if (context != null) {
                    V8Function jsFunc = (V8Function) (func.contains(".") ? context.executeScript(func, "") : context.get(func));
                    V8Array jsArgs = new V8Array(context);
                    for (int i = 0; i < args.size(); i++) {
                        Object v = transformFlutterObjectToV8Object(context, args.get(i));
                        if (v instanceof V8Value) {
                            jsArgs.push((V8Value) v);
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
                    result.success(transformV8ObjectToFlutterObject(ret));
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
                V8 context = contextRefs.get(contextRef);
                if (context != null) {
                    V8Function jsFunction = (V8Function) context.executeScript("MPJS.instance.handleMessage", "");
                    V8Array args = new V8Array(context);
                    args.push((V8Value) transformFlutterObjectToV8Object(context, message));
                    args.push(new V8Function(context, new JavaCallback() {
                        @Override
                        public Object invoke(V8Object v8Object, V8Array v8Array) {
                            result.success(v8Array.toString());
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

    private Object transformV8ObjectToFlutterObject(Object v8Object) {
        if (v8Object instanceof V8Array) {
            List list = new ArrayList();
            for (int i = 0; i < ((V8Array)v8Object).length(); i++) {
                list.add(transformV8ObjectToFlutterObject(((V8Array)v8Object).get(i)));
            }
            return list;
        }
        else if (v8Object instanceof V8Object) {
            if (((V8Object) v8Object).isUndefined()) {
                return null;
            }
            Map map = new HashMap();
            String[] keys = ((V8Object) v8Object).getKeys();
            for (String key : keys) {
                Object obj = ((V8Object) v8Object).get(key);
                int type = ((V8Object) v8Object).getType(key);
                if (type == V8.UNDEFINED || obj instanceof V8Function) {
                    continue;
                }
                if (obj instanceof Number || obj instanceof String || obj instanceof Boolean) {
                    map.put(key, obj);
                } else if (obj instanceof V8Array) {
                    map.put(key, transformV8ObjectToFlutterObject(obj));
                } else if (obj instanceof V8Object) {
                    map.put(key, transformV8ObjectToFlutterObject(obj));
                }
            }
            return map;
        }
        else {
            return v8Object;
        }
    }

    private void hashArray(V8 context,List lhm1, V8Array objaray)  {
        for (int i = 0; i < lhm1.size(); i++) {
            Object value = lhm1.get(i);
            if (value instanceof String) {

                objaray.push((String)value);
            }
            else if (value instanceof List) {


                V8Array subobjaray = new V8Array(context);
                hashArray(context,(List) value,subobjaray);
            }
            else if (value instanceof Boolean) {


                objaray.push((boolean)value);
            }
            else if (value instanceof Double) {


                objaray.push((double)value);
            }
            else if (value instanceof Integer) {


                objaray.push((int)value);
            }
            else if (value instanceof V8Value) {


                objaray.push((V8Value)value);
            }

            else if (value instanceof Map) {
                V8Object obj = new V8Object(context);
                Map<String, Object> subMap = (Map<String, Object>)value;
                hashMapper(context,subMap,obj);



            } else {

            }
        }
    }

    private void hashMapper(V8 context,Map<String, Object> lhm1,V8Object obj)  {
        try {
            for (Map.Entry<String, Object> entry : lhm1.entrySet()) {
                String key = entry.getKey();
                Object value = entry.getValue();

                if (value instanceof String) {

                    obj.add(key,  (String)value);
                }
                else if (value instanceof List) {
                    V8Array objaray = new V8Array(context);
                    hashArray(context,(List) value,objaray);

                    obj.add(key, objaray );
                }
                else if (value instanceof Boolean) {

                    obj.add(key,  (boolean)value);
                }
                else if (value instanceof Double) {

                    obj.add(key,  (double)value);
                }
                else if (value instanceof Integer) {

                    obj.add(key,  (int)value);
                }
                else if (value instanceof V8Value) {

                    obj.add(key,  (V8Value)value);
                }

                else if (value instanceof Map) {
                    Map<String, Object> subMap = (Map<String, Object>)value;

                    V8Object sss = new V8Object(context);
                    hashMapper(context,subMap,sss);
                    obj.add(key,sss);
                } else {

                }

            }
            System.out.println(obj);
        }catch (Throwable e){
            System.out.println(e.toString());
        }
    }

    private Object transformFlutterObjectToV8Object(V8 context, Object v8Object) {
        if (v8Object instanceof V8Object) {
            return v8Object;
        }

        else if (v8Object instanceof List) {
            V8Array obj = new V8Array(context);
            List v = (List)v8Object;
            for (int i = 0; i < v.size(); i++) {
                obj.push(transformFlutterObjectToV8Object(context, v.get(i)));
            }
            return obj;
        }
        else if (v8Object instanceof Map) {
            V8Object obj = new V8Object(context);

            hashMapper(context,(Map)v8Object,obj);

            return obj;
        }
        else {
            return v8Object;
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
