package com.mpflutter.runtime.api;

import com.eclipsesource.v8.V8;
import com.eclipsesource.v8.V8Object;

public class MPDeviceInfo {

    static public void setupWithJSContext(V8 context) {
        V8Object document = new V8Object(context);
        document.add("currentScript", "");
        V8Object body = new V8Object(context);
        body.add("clientWidth", 375);
        body.add("clientHeight", 667);
        body.add("windowPaddingTop", 0);
        body.add("windowPaddingBottom", 0);
        document.add("body", body);
        context.add("document", document);
        context.add("enableMPProxy", true);
//        context.set("disableMPProxy", true);

    }

}
