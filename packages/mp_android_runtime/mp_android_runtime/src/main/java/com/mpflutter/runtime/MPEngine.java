package com.mpflutter.runtime;

import android.content.Context;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import com.eclipsesource.v8.JavaCallback;
import com.eclipsesource.v8.V8;
import com.eclipsesource.v8.V8Array;
import com.eclipsesource.v8.V8Function;
import com.eclipsesource.v8.V8Object;
import com.facebook.drawee.backends.pipeline.DraweeConfig;
import com.facebook.drawee.backends.pipeline.Fresco;
import com.facebook.imagepipeline.core.ImagePipelineConfig;
import com.facebook.imagepipeline.decoder.ImageDecoderConfig;
import com.mpflutter.runtime.api.MPConsole;
import com.mpflutter.runtime.api.MPDeviceInfo;
import com.mpflutter.runtime.api.MPFlutterPlatform;
import com.mpflutter.runtime.api.MPNetworkHttp;
import com.mpflutter.runtime.api.MPStorage;
import com.mpflutter.runtime.api.MPTimer;
import com.mpflutter.runtime.api.MPWXCompat;
import com.mpflutter.runtime.components.MPComponentFactory;
import com.mpflutter.runtime.components.MPComponentView;
import com.mpflutter.runtime.components.basic.CustomPaint;
import com.mpflutter.runtime.components.basic.CustomScrollView;
import com.mpflutter.runtime.components.basic.DrawableStorage;
import com.mpflutter.runtime.components.basic.GridView;
import com.mpflutter.runtime.components.basic.ListView;
import com.mpflutter.runtime.components.basic.WebDialogs;
import com.mpflutter.runtime.components.mpkit.MPJS;
import com.mpflutter.runtime.components.mpkit.MPPlatformView;
import com.mpflutter.runtime.debugger.MPDebugger;
import com.mpflutter.runtime.jsproxy.JSProxyArray;
import com.mpflutter.runtime.jsproxy.JSProxyObject;
import com.mpflutter.runtime.platform.MPPlatformChannelIO;
import com.mpflutter.runtime.platform.MPPluginRegister;
import com.mpflutter.runtime.provider.MPProvider;

import org.json.JSONObject;

import java.io.IOException;
import java.io.InputStream;
import java.lang.ref.WeakReference;
import java.nio.charset.Charset;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class MPEngine {

    static Map<Integer, WeakReference<MPEngine>> engineStore = new HashMap();

    private boolean started = false;
    private String jsCode;
    public V8 jsContext;
    public Context context;
    public MPDebugger debugger;
    public MPMPKReader mpkReader;
    public Handler mainThreadHandler;
    public MPTextMeasurer textMeasurer;
    public MPWindowInfo windowInfo;
    public MPRouter router;
    public MPJS mpjs;
    public DrawableStorage drawableStorage;
    public MPComponentFactory componentFactory;
    public MPPlatformChannelIO platformChannelIO;
    public Map<Integer, MPDataReceiver> managedViews = new HashMap();
    public Map<Integer, List<JSProxyObject>> managedViewsQueueMessage = new HashMap();
    public MPProvider provider;
    V8Object engineScope;
    String initialRoute;
    Map initialParams;

    public MPEngine(Context context) {
        this.context = context;
        initializePlatforms();
        initializeFresco(context);
        mainThreadHandler = new Handler(Looper.getMainLooper());
        textMeasurer = new MPTextMeasurer(this);
        windowInfo = new MPWindowInfo(this);
        router = new MPRouter(this);
        componentFactory = new MPComponentFactory(context, this);
        platformChannelIO = new MPPlatformChannelIO(this);
        drawableStorage = new DrawableStorage(this);
        engineStore.put(this.hashCode(), new WeakReference(this));
        provider = new MPProvider(context);
    }

    void initializePlatforms() {
        MPPluginRegister.registerChannel("flutter/platform", MPFlutterPlatform.class);
    }

    void initializeFresco(Context context) {
        ImageDecoderConfig decoderConfig = ImageDecoderConfig.newBuilder().addDecodingCapability(MPSVGImageDecoder.SVG_FORMAT, new MPSVGImageDecoder.SvgFormatChecker(), new MPSVGImageDecoder.SvgDecoder()).build();
        ImagePipelineConfig pipelineConfig = ImagePipelineConfig.newBuilder(context).setDownsampleEnabled(true).setImageDecoderConfig(decoderConfig).build();
        DraweeConfig draweeConfig = DraweeConfig.newBuilder().addCustomDrawableFactory(new MPSVGImageDecoder.SvgDrawableFactory()).build();
        Fresco.initialize(context, pipelineConfig, draweeConfig);
    }

    public void initWithJSCode(String code) {
        jsCode = code;
    }

    public void initWithDebuggerServerAddr(String debuggerServerAddr) {
        debugger = new MPDebugger(this, debuggerServerAddr);
    }

    public void initWithMpkData(InputStream inputStream) throws IOException {
        mpkReader = new MPMPKReader();
        mpkReader.setInputStream(inputStream);
        byte[] mainDartJSData = mpkReader.dataWithFilePath("main.dart.js");
        if (mainDartJSData != null) {
            jsCode = new String(mainDartJSData, Charset.forName("utf-8"));
            Log.d("MPRuntime", "initWithMpkData: ");
        }
    }

    public void start() {
        if (started) {
            return;
        }
        jsContext = V8.createV8Runtime("self");
        setupJSContextEventChannel();
        setupDeferredLibraryLoader();
        MPTimer.setupWithJSContext(jsContext);
        MPConsole.setupWithJSContext(jsContext);
        MPDeviceInfo.setupWithJSContext(jsContext);
        MPWXCompat.setupWithJSContext(jsContext);
        MPNetworkHttp.setupWithJSContext(this, jsContext);
        MPStorage.setupWithJSContext(this, jsContext);
        mpjs = new MPJS(this);
        if (jsCode != null) {
            try {
                Log.d("MPRuntime", "start execcode: ");
                jsContext.executeVoidScript(jsCode);
                Log.d("MPRuntime", "end execcode: ");
            } catch (Throwable e) {
                Log.e(MPRuntime.TAG, "error: ", e);
            }
        }
        else if (debugger != null) {
            debugger.start();
        }
        windowInfo.updateWindowInfo();
        started = true;
    }

    public void stop() {}

    public void clear() {
        componentFactory.clear();
    }

    void setupJSContextEventChannel() {
        this.engineScope = new V8Object(jsContext);
        engineScope.registerJavaMethod(new JavaCallback() {
            @Override
            public Object invoke(V8Object v8Object, V8Array v8Array) {
                try {
                    String message = v8Array.getString(0);
                    JSProxyObject obj = new JSProxyObject(new JSONObject(message));
                    didReceivedMessage(obj);
                } catch (Throwable e) {
                    e.printStackTrace();
                }
                return null;
            }
        }, "onMessage");
        engineScope.registerJavaMethod(new JavaCallback() {
            @Override
            public Object invoke(V8Object v8Object, V8Array v8Array) {
                try {
                    JSProxyObject obj = new JSProxyObject(v8Array.getObject(0));
                    didReceivedMessage(obj);
                } catch (Throwable e) {
                    e.printStackTrace();
                }
                return null;
            }
        }, "onMapMessage");
        jsContext.add("engineScope", engineScope);
    }

    void setupDeferredLibraryLoader() {
        jsContext.registerJavaMethod(new JavaCallback() {
            @Override
            public Object invoke(V8Object v8Object, V8Array v8Array) {
                if (mpkReader == null) return null;
                if (v8Array.length() < 3) return null;
                String fileName = v8Array.getString(0);
                V8Function resFunc = (V8Function) v8Array.get(1);
                V8Function rejFunc = (V8Function) v8Array.get(2);
                byte[] codeData = mpkReader.dataWithFilePath(fileName);
                if (codeData == null) {
                    rejFunc.call(null, new V8Array(v8Object.getRuntime()));
                    return null;
                }
                String code = new String(codeData);
                if (code == null) {
                    rejFunc.call(null, new V8Array(v8Object.getRuntime()));
                    return null;
                }
                try {
                    jsContext.executeVoidScript(code);
                    resFunc.call(null, new V8Array(v8Object.getRuntime()));
                } catch (Throwable e) {
                    rejFunc.call(null, new V8Array(v8Object.getRuntime()));
                }
                return null;
            }
        }, "dartDeferredLibraryLoader");
    }

    public void sendMessage(Map message) {
        Log.d(MPRuntime.TAG, "[out] type: " + message.get("type"));
        String data = new JSONObject(message).toString();
        if (debugger != null) {
            debugger.sendMessage(data);
        }
        else {
             try {
                 if (this.engineScope != null) {
                     this.engineScope.executeJSFunction("postMessage", data);
                 }
             } catch (Throwable e) {
                 Log.e(MPRuntime.TAG, "sendMessage: ", e);
             }
        }
    }

    public void didReceivedMessage(JSProxyObject decodedMessage) {
        mainThreadHandler.post(new Runnable() {
            @Override
            public void run() {
                try {
                    String type = decodedMessage.optString("type", "");
                    Log.d(MPRuntime.TAG, "[in] type: " + type);
                    if (type.equalsIgnoreCase("frame_data")) {
                        didReceivedFrameData(decodedMessage.optObject("message"));
                    } else if (type.equalsIgnoreCase("diff_data")) {
                        didReceivedDiffData(decodedMessage.optObject("message"));
                    } else if (type.equalsIgnoreCase("element_gc")) {
                        didReceivedElementGC(decodedMessage.optArray("message"));
                    } else if (type.equalsIgnoreCase("decode_drawable")) {
                        drawableStorage.decodeDrawable(decodedMessage.optObject("message"));
                    } else if (type.equalsIgnoreCase("custom_paint")) {
                        CustomPaint.didReceivedCustomPaintMessage(decodedMessage.optObject("message"), MPEngine.this);
                    } else if (type.equalsIgnoreCase("action:web_dialogs")) {
                        WebDialogs.didReceivedWebDialogsMessage(decodedMessage.optObject("message"), MPEngine.this);
                    } else if (type.equalsIgnoreCase("route")) {
                        router.didReceivedRouteData(decodedMessage.optObject("message"));
                    } else if (type.equalsIgnoreCase("mpjs")) {
                        mpjs.didReceivedMessage(decodedMessage.optObject("message"));
                    } else if (type.equalsIgnoreCase("rich_text")) {
                        textMeasurer.didReceivedDoMeasureData(decodedMessage.optObject("message"));
                    } else if (type.equalsIgnoreCase("platform_view")) {
                        MPPlatformView.didReceivedPlatformViewMessage(decodedMessage.optObject("message"), MPEngine.this);
                    } else if (type.equalsIgnoreCase("scroll_view")) {
                        didReceivedScrollView(decodedMessage.optObject("message"));
                    } else if (type.equalsIgnoreCase("platform_channel")) {
                        platformChannelIO.didReceivedMessage(decodedMessage.optObject("message"));
                    }
                } catch (Throwable e) {
                    e.printStackTrace();
                }
            }
        });
    }

    private void didReceivedFrameData(JSProxyObject frameData) {
        if (frameData == null) return;
        int routeId = frameData.optInt("routeId", -1);
        if (routeId >= 0 && managedViews.containsKey(routeId)) {
            managedViews.get(routeId).didReceivedFrameData(frameData);
        }
        else if (routeId >= 0) {
            List<JSProxyObject> queue;
            if (!managedViewsQueueMessage.containsKey(routeId)) {
                managedViewsQueueMessage.put(routeId, new ArrayList());
            }
            queue = managedViewsQueueMessage.get(routeId);
            queue.add(frameData);
        }
    }

    private void didReceivedDiffData(JSProxyObject frameData) {
        if (frameData == null) return;
        JSProxyArray diffs = frameData.optArray("diffs");
        if (diffs != null) {
            for (int i = 0; i < diffs.length(); i++) {
                JSProxyObject obj = diffs.optObject(i);
                if (obj != null) {
                    componentFactory.create(obj);
                }
            }
        }
    }

    private void didReceivedElementGC(JSProxyArray data) {
        if (data == null) return;
        for (int i = 0; i < data.length(); i++) {
            componentFactory.cachedView.remove(i);
            componentFactory.cachedElement.remove(i);
        }
    }

    private void didReceivedScrollView(JSProxyObject message) {
        String event = message.optString("event", null);
        if (event != null && event.contentEquals("onRefreshEnd")) {
            int target = message.optInt("target", 0);
            MPComponentView targetView = componentFactory.cachedView.get(target);
            if (targetView != null) {
                if (targetView instanceof ListView) {
                    ((ListView) targetView).endRefresh();
                }
                else if (targetView instanceof GridView) {
                    ((GridView) targetView).endRefresh();
                }
                else if (targetView instanceof CustomScrollView) {
                    ((CustomScrollView) targetView).endRefresh();
                }
            }
        }
    }

}
