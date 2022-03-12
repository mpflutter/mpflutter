package com.mpflutter.runtime.api;

import com.eclipsesource.v8.JavaCallback;
import com.eclipsesource.v8.V8;
import com.eclipsesource.v8.V8Array;
import com.eclipsesource.v8.V8Object;

public class MPWXCompat {

    static public void setupWithJSContext(V8 context) {
        injectWXScope(context);
    }

    static private void injectWXScope(V8 context) {
        V8Object wx = new V8Object(context);
        wx.registerJavaMethod(new JavaCallback() {
            @Override
            public Object invoke(V8Object v8Object, V8Array v8Array) {
                String v = v8Array.getString(0);
                if (v != null) {
                    return v;
                }
                return null;
            }
        }, "arrayBufferToBase64");
        context.add("wx", wx);
    }

}
