package com.mpflutter.runtime.api;

import com.quickjs.JSArray;
import com.quickjs.JSContext;
import com.quickjs.JSFunction;
import com.quickjs.JSObject;
import com.quickjs.JavaCallback;

public class MPWXCompat {

    static public void setupWithJSContext(JSContext context, JSObject selfObject) {
        injectWXScope(context, selfObject);
    }

    static private void injectWXScope(JSContext context, JSObject selfObject) {
        JSObject wx = new JSObject(context);
        wx.set("arrayBufferToBase64", new JSFunction(context, new JavaCallback() {
            @Override
            public Object invoke(JSObject receiver, JSArray args) {
                String v = args.getString(0);
                if (v != null) {
                    return v;
                }
                return null;
            }
        }));
        context.set("wx", wx);
        selfObject.set("wx", wx);
    }

}
