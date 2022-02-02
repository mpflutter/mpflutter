package com.mpflutter.sample;

import com.mpflutter.runtime.platform.MPMethodChannel;
import com.mpflutter.runtime.platform.MPMethodChannelCallback;

import java.util.HashMap;

public class MPTemplateMethodChannel extends MPMethodChannel {

    @Override
    public void onMethodCall(String method, Object params, MPMethodChannelCallback result) {
        if (method.contentEquals("getDeviceName")) {
            invokeMethod("getCallerName", new HashMap(), new MPMethodChannelCallback(){
                @Override
                public void success(Object ret) {
                    result.success(ret.toString() + " on Android");
                }
            });
        }
        else {
            result.fail("NOT_IMPLEMENTED");
        }
    }
}
