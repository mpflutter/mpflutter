package com.mpflutter.runtime.platform;

import com.mpflutter.runtime.components.MPComponentFactory;

import java.util.HashMap;
import java.util.Map;

public class MPPluginRegister {

    static final Map<String, Class> registedChannels = new HashMap();

    static public void registerChannel(String name, Class clazz) {
        registedChannels.put(name, clazz);
    }

    static public void registerPlatformView(String name, Class clazz) {
        MPComponentFactory.components.put(name, clazz);
    }

}
