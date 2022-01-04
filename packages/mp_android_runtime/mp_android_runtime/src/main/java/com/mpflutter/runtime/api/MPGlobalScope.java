package com.mpflutter.runtime.api;

import com.quickjs.JSContext;
import com.quickjs.JSObject;

public class MPGlobalScope {

    static public void setupWithJSContext(JSContext context, JSObject selfObject) {
        selfObject.set("Object", context.getObject("Object"));
    }

}
