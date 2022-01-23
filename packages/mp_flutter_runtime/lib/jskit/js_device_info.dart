part of '../mp_flutter_runtime.dart';

class _JSDeviceInfo {
  static Future install(
    _JSContext context,
    BuildContext flutterContext,
  ) async {
    context.evaluateScript('''
    let document = {
      currentScript: '',
      body: {
        clientWidth: ${MediaQuery.of(flutterContext).size.width},
        clientHeight: ${MediaQuery.of(flutterContext).size.height},
        windowPaddingTop: ${MediaQuery.of(flutterContext).padding.top},
        windowPaddingBottom: ${MediaQuery.of(flutterContext).padding.bottom},
      },
    };
    globalThis.document = document;
    globalThis.disableMPProxy = true;
    globalThis.devicePixelRatio = ${MediaQuery.of(flutterContext).devicePixelRatio};
    ''');
  }
}
