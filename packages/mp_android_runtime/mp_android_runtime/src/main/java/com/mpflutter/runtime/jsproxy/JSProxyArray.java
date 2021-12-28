package com.mpflutter.runtime.jsproxy;

import com.quickjs.JSArray;
import com.quickjs.JSObject;

import org.json.JSONArray;
import org.json.JSONObject;

public class JSProxyArray {

    private JSONArray jsonArray;
    private JSArray qjsArray;

    public JSProxyArray(JSONArray jsonArray) {
        this.jsonArray = jsonArray;
    }

    public JSProxyArray(JSArray qjsArray) {
        this.qjsArray = qjsArray;
    }

    public int length() {
        if (jsonArray != null) {
            return jsonArray.length();
        }
        else if (qjsArray != null) {
            return qjsArray.length();
        }
        else {
            return 0;
        }
    }

    public String optString(int key, String fallback) {
        if (jsonArray != null) {
            return jsonArray.optString(key, fallback);
        }
        else if (qjsArray != null) {
            Object v = valueFromQjsObject(key);
            if (v instanceof String) {
                return (String) v;
            }
        }
        return fallback;
    }

    public int optInt(int key) {
        return optInt(key, 0);
    }

    public int optInt(int key, int fallback) {
        if (jsonArray != null) {
            return jsonArray.optInt(key, fallback);
        }
        else if (qjsArray != null) {
            Object v = valueFromQjsObject(key);
            if (v instanceof Number) {
                return ((Number) v).intValue();
            }
        }
        return fallback;
    }

    public double optDouble(int key) {
        return optDouble(key, 0.0);
    }

    public double optDouble(int key, double fallback) {
        if (jsonArray != null) {
            return jsonArray.optDouble(key, fallback);
        }
        else if (qjsArray != null) {
            Object v = valueFromQjsObject(key);
            if (v instanceof Number) {
                return ((Number) v).doubleValue();
            }
        }
        return fallback;
    }

    public boolean optBoolean(int key) {
        return optBoolean(key, false);
    }

    public boolean optBoolean(int key, boolean fallback) {
        if (jsonArray != null) {
            return jsonArray.optBoolean(key, fallback);
        }
        else if (qjsArray != null) {
            Object v = valueFromQjsObject(key);
            if (v instanceof Boolean) {
                return (boolean) v;
            }
        }
        return fallback;
    }

    public JSProxyObject optObject(int key) {
        if (jsonArray != null) {
            JSONObject obj = jsonArray.optJSONObject(key);
            if (obj != null) {
                return new JSProxyObject(obj);
            }
        }
        else if (qjsArray != null) {
            Object v = valueFromQjsObject(key);
            if (v instanceof JSObject) {
                return new JSProxyObject((JSObject) v);
            }
        }
        return null;
    }

    public JSProxyArray optArray(int key) {
        if (jsonArray != null) {
            JSONArray obj = jsonArray.optJSONArray(key);
            if (obj != null) {
                return new JSProxyArray(obj);
            }
        }
        else if (qjsArray != null) {
            Object v = valueFromQjsObject(key);
            if (v instanceof JSArray) {
                return new JSProxyArray((JSArray) v);
            }
        }
        return null;
    }

    Object valueFromQjsObject(int key) {
        return qjsArray.get(key);
    }
}
