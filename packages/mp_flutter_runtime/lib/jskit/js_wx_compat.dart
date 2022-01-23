part of '../mp_flutter_runtime.dart';

class _JSWXCompat {
  static Future install(_JSContext context) async {
    await context.evaluateScript('''
    globalThis.wx = {
      arrayBufferToBase64: function(value) {
        if (typeof value === 'string') {
          return value;
        }
      },
    };
    ''');
  }
}
