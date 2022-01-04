package com.mpflutter.runtime.api;

import com.quickjs.JSContext;
import com.quickjs.JSObject;

public class MPGlobalScope {

    static public void setupWithJSContext(JSContext context, JSObject selfObject) {
        selfObject.set("Object", context.getObject("Object"));
        selfObject.set("JSON", context.getObject("JSON"));
        selfObject.set("Promise", context.getObject("Promise"));
        selfObject.set("Proxy", context.getObject("Proxy"));
        selfObject.set("Symbol", context.getObject("Symbol"));
        selfObject.set("Reflect", context.getObject("Reflect"));
        selfObject.set("Set", context.getObject("Set"));
        selfObject.set("Map", context.getObject("Map"));
    }

}
