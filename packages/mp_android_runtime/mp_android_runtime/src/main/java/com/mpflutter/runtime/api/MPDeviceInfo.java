package com.mpflutter.runtime.api;

import com.quickjs.JSContext;
import com.quickjs.JSObject;

public class MPDeviceInfo {

    static public void setupWithJSContext(JSContext context, JSObject selfObject) {
        JSObject document = new JSObject(context);
        document.set("currentScript", "");
        JSObject body = new JSObject(context);
        body.set("clientWidth", 375);
        body.set("clientHeight", 667);
        body.set("windowPaddingTop", 0);
        body.set("windowPaddingBottom", 0);
        document.set("body", body);
        context.set("document", document);
        context.set("enableMPProxy", true);
//        context.set("disableMPProxy", true);
        selfObject.set("document", document);
        selfObject.set("enableMPProxy", true);
//        selfObject.set("disableMPProxy", true);

    }

}