package com.mpflutter.runtime;

import android.util.Log;

import com.mpflutter.runtime.api.MPConsole;
import com.mpflutter.runtime.api.MPDeviceInfo;
import com.mpflutter.runtime.api.MPTimer;
import com.quickjs.JSContext;
import com.quickjs.QuickJS;

public class MPEngine {

    private boolean started = false;
    private String jsCode;
    private QuickJS quickJS;
    private JSContext jsContext;

    public void initWithJSCode(String code) {
        this.jsCode = code;
    }

    public void initWithDebuggerServerAddr(String debuggerServerAddr) {

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

        try {
//            jsContext.executeScript("console.log('123213', 123.0, true, 321)", "");
//            jsContext.executeScript("var s = setInterval(() => { console.log('fkhdsalkfh'); return 123; }, 1000);", "");
        } catch (Throwable e) {
            Log.e("MPRuntime", "start: ", e);
        }
    }

    public void stop() {}

}
