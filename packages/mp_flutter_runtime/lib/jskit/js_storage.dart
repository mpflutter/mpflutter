part of '../mp_flutter_runtime.dart';

class _JSStorage {
  static Future install(_JSContext context, MPEngine engine) async {
    final instance =
        await engine.provider.dataProvider.createSharedPreferences();
    context.addMessageListener((message, type) {
      if (type == '\$wx.storage') {
        final data = json.decode(message);
        if (data['func'] == 'removeStorageSync') {
          instance.remove(data['key']);
        } else if (data['func'] == 'setStorageSync') {
          final value = data['value'];
          if (value is bool) {
            instance.setBool(data['key'], value);
          } else if (value is String) {
            instance.setString(data['key'], value);
          } else if (value is int) {
            instance.setInt(data['key'], value);
          } else if (value is double) {
            instance.setDouble(data['key'], value);
          }
        }
      }
    });
    final allValues = {};
    instance.getKeys().forEach((element) {
      final v = instance.get(element);
      if (v is String) {
        allValues[element] = v.replaceAll('"', '!@#');
      }
    });
    final encodedValues = json.encode(allValues);
    await context.evaluateScript('''
    let storageValues = JSON.parse('$encodedValues');
    globalThis.wx.removeStorageSync = function(key) {
      delete storageValues[key];
      globalThis.postMessage(JSON.stringify({func: 'removeStorageSync', key: key}), '\$wx.storage');
    };
    globalThis.wx.getStorageSync = function(key) {
      let v = storageValues[key];
      if (typeof v !== "string") return v;
      return v.replace(/!@#/g, '"');
    };
    globalThis.wx.setStorageSync = function(key, value) {
      storageValues[key] = value;
      return globalThis.postMessage(JSON.stringify({func: 'setStorageSync', key: key, value: value}), '\$wx.storage');
    };
    globalThis.wx.getStorageInfoSync = function() {
      return {keys: Object.keys(storageValues)};
    };
    ''');
  }
}
