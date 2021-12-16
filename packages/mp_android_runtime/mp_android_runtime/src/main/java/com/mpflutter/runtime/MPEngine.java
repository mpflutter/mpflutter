package com.mpflutter.runtime;

import android.content.Context;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import com.facebook.drawee.backends.pipeline.Fresco;
import com.mpflutter.runtime.api.MPConsole;
import com.mpflutter.runtime.api.MPDeviceInfo;
import com.mpflutter.runtime.api.MPTimer;
import com.mpflutter.runtime.components.MPComponentFactory;
import com.mpflutter.runtime.debugger.MPDebugger;
import com.quickjs.JSContext;
import com.quickjs.QuickJS;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;
import java.util.Map;

public class MPEngine {

    private boolean started = false;
    private String jsCode;
    private QuickJS quickJS;
    private JSContext jsContext;
    public MPDebugger debugger;
    Handler mainThreadHandler;
    MPTextMeasurer textMeasurer;
    MPRouter router;
    MPComponentFactory componentFactory;
    Map<Integer, MPDataReceiver> managedViews = new HashMap();

    public MPEngine(Context context) {
        Fresco.initialize(context);
        mainThreadHandler = new Handler(Looper.getMainLooper());
        textMeasurer = new MPTextMeasurer(this);
        router = new MPRouter(this);
        componentFactory = new MPComponentFactory(context, this);
    }

    public void initWithJSCode(String code) {
        jsCode = code;
    }

    public void initWithDebuggerServerAddr(String debuggerServerAddr) {
        debugger = new MPDebugger(this, debuggerServerAddr);
    }

    public void start() {
        if (started) {
            return;
        }
        quickJS = QuickJS.createRuntime();
        jsContext = quickJS.createContext();

        MPTimer.setupWithJSContext(jsContext);
        MPConsole.setupWithJSContext(jsContext);
        MPDeviceInfo.setupWithJSContext(jsContext);

        jsContext.set("self", jsContext);
        if (jsCode != null) {
            try {
                jsContext.executeVoidScript(jsCode, "");
            } catch (Throwable e) {
                Log.e(MPRuntime.TAG, "error: ", e);
            }
        }
        else if (debugger != null) {
            debugger.start();
        }
        started = true;
    }

    public void stop() {}

    public void sendMessage(Map message) {
         String data = new JSONObject(message).toString();
         if (debugger != null) {
             debugger.sendMessage(data);
         }
    }

    public void didReceivedMessage(String message) {
        mainThreadHandler.post(new Runnable() {
            @Override
            public void run() {
                try {
                    JSONObject decodedMessage = new JSONObject(message);
                    String type = decodedMessage.getString("type");
                    if (type.equalsIgnoreCase("frame_data")) {
                        didReceivedFrameData(decodedMessage.getJSONObject("message"));
                    } else if (type.equalsIgnoreCase("route")) {
                        router.didReceivedRouteData(decodedMessage.getJSONObject("message"));
                    } else if (type.equalsIgnoreCase("rich_text")) {
                        textMeasurer.didReceivedDoMeasureData(decodedMessage.getJSONObject("message"));
                    }
                } catch (JSONException e) {
                    e.printStackTrace();
                }
            }
        });
    }

    private void didReceivedFrameData(JSONObject frameData) throws JSONException {
        int routeId = frameData.getInt("routeId");
        if (managedViews.containsKey(routeId)) {
            managedViews.get(routeId).didReceivedFrameData(frameData);
        }
    }

}
