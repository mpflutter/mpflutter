package com.mpflutter.runtime.jsproxy;

import com.eclipsesource.v8.V8;
import com.eclipsesource.v8.V8Array;
import com.eclipsesource.v8.V8Object;

import org.json.JSONArray;
import org.json.JSONObject;

public class JSProxyObject {

    public JSONObject jsonObject;
    public V8Object qV8Object;

    public JSProxyObject(JSONObject jsonObject) {
        this.jsonObject = jsonObject;
    }

    public JSProxyObject(V8Object qV8Object) {
        this.qV8Object = qV8Object;
    }

    public String optString(String key, String fallback) {
        if (jsonObject != null) {
            if (jsonObject.isNull(key)) {
                return fallback;
            }
            return jsonObject.optString(key, fallback);
        }
        else if (qV8Object != null) {
            Object v = valueFromQV8Object(key);
            if (v instanceof String) {
                return (String) v;
            }
        }
        return fallback;
    }

    public int optInt(String key) {
        return optInt(key, 0);
    }

    public int optInt(String key, int fallback) {
        if (jsonObject != null) {
            if (jsonObject.isNull(key)) {
                return fallback;
            }
            return jsonObject.optInt(key, fallback);
        }
        else if (qV8Object != null) {
            Object v = valueFromQV8Object(key);
            if (v instanceof Number) {
                return ((Number) v).intValue();
            }
        }
        return fallback;
    }

    public double optDouble(String key) {
        return optDouble(key, 0.0);
    }

    public double optDouble(String key, double fallback) {
        if (jsonObject != null) {
            if (jsonObject.isNull(key)) {
                return fallback;
            }
            return jsonObject.optDouble(key, fallback);
        }
        else if (qV8Object != null) {
            Object v = valueFromQV8Object(key);
            if (v instanceof Number) {
                return ((Number) v).doubleValue();
            }
        }
        return fallback;
    }

    public boolean optBoolean(String key) {
        return optBoolean(key, false);
    }

    public boolean optBoolean(String key, boolean fallback) {
        if (jsonObject != null) {
            if (jsonObject.isNull(key)) {
                return fallback;
            }
            return jsonObject.optBoolean(key, fallback);
        }
        else if (qV8Object != null) {
            Object v = valueFromQV8Object(key);
            if (v instanceof Boolean) {
                return (boolean) v;
            }
        }
        return fallback;
    }

    public JSProxyObject optObject(String key) {
        if (jsonObject != null) {
            Object obj = jsonObject.opt(key);
            if (obj instanceof JSONObject) {
                return new JSProxyObject((JSONObject) obj);
            }
            else if (obj instanceof JSProxyObject) {
                return (JSProxyObject) obj;
            }
        }
        else if (qV8Object != null) {
            Object v = valueFromQV8Object(key);
            if (v instanceof V8Object) {
                return new JSProxyObject((V8Object) v);
            }
        }
        return null;
    }

    public JSProxyArray optArray(String key) {
        if (jsonObject != null) {
            Object obj = jsonObject.opt(key);
            if (obj instanceof JSONArray) {
                return new JSProxyArray((JSONArray) obj);
            }
            else if (obj instanceof JSProxyArray) {
                return (JSProxyArray) obj;
            }
        }
        else if (qV8Object != null) {
            Object v = valueFromQV8Object(key);
            if (v instanceof V8Array) {
                return new JSProxyArray((V8Array) v);
            }
        }
        return null;
    }

    Object valueFromQV8Object(String key) {
        V8Object o = qV8Object;
        if (qV8Object.contains("o") && qV8Object.getType("o") == V8.V8_OBJECT) {
            o = qV8Object.getObject("o");
        }
        if (o != null && o.getV8Type() == V8.V8_OBJECT) {
            if (o.contains("b")) {
                V8Object b = o.getObject("b");
                if (b != null && b.getV8Type() == V8.V8_OBJECT) {
                    V8Object obj = b.getObject(key);
                    if (obj != null && obj.getV8Type() == V8.V8_OBJECT) {
                        return obj.get("b");
                    }
                }
            }
            else if (o.contains("c")) {
                V8Object c = o.getObject("c");
                if (c != null && c.getV8Type() == V8.V8_OBJECT) {
                    V8Object obj = c.getObject(key);
                    if (obj != null && obj.getV8Type() == V8.V8_OBJECT) {
                        return obj.get("b");
                    }
                }
            }
            else if (o.contains("_nums")) {
                V8Object _nums = o.getObject("_nums");
                if (_nums != null && _nums.getV8Type() == V8.V8_OBJECT) {
                    V8Object obj = _nums.getObject(key);
                    if (obj != null && obj.getV8Type() == V8.V8_OBJECT) {
                        return obj.get("hashMapCellValue");
                    }
                }
            }
            else if (o.contains("_strings")) {
                V8Object _strings = o.getObject("_strings");
                if (_strings != null && _strings.getV8Type() == V8.V8_OBJECT) {
                    V8Object obj = _strings.getObject(key);
                    if (obj != null && obj.getV8Type() == V8.V8_OBJECT) {
                        return obj.get("hashMapCellValue");
                    }
                }
            }
            else if (o.contains(key)) {
                return o.get(key);
            }
        }
        return null;
    }

    public boolean has(String key) {
        if (jsonObject != null) {
            return jsonObject.has(key) && !jsonObject.isNull(key);
        }
        else if (qV8Object != null) {
            return !isNull(key);
        }
        else {
            return false;
        }
    }

    public boolean isNull(String key) {
        if (jsonObject != null) {
            return jsonObject.isNull(key);
        }
        else if (qV8Object != null) {
            Object v = valueFromQV8Object(key);
            return v == null;
        }
        else {
            return false;
        }
    }

    public Object opt(String key) {
        Object v = null;
        if (jsonObject != null) {
            v = jsonObject.opt(key);
        }
        else if (qV8Object != null) {
            v = valueFromQV8Object(key);
        }
        if (v instanceof JSONObject) {
            return new JSProxyObject((JSONObject) v);
        }
        else if (v instanceof V8Object) {
            return new JSProxyObject((V8Object) v);
        }
        else if (v instanceof JSONArray) {
            return new JSProxyArray((JSONArray) v);
        }
        else if (v instanceof V8Array) {
            return new JSProxyArray((V8Array) v);
        }
        return v;
    }

}
