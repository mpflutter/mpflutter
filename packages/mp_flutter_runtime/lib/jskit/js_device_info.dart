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

// JSValue *document = [JSValue valueWithNewObjectInContext:context];
//     document[@"currentScript"] = @"";
//     JSValue *body = [JSValue valueWithNewObjectInContext:context];
//     if (CGSizeEqualToSize(CGSizeZero, size)) {
//         body[@"clientWidth"] = [JSValue valueWithDouble:UIScreen.mainScreen.bounds.size.width
//                                               inContext:context];
//         body[@"clientHeight"] = [JSValue valueWithDouble:UIScreen.mainScreen.bounds.size.height
//                                               inContext:context];
//     }
//     else {
//         body[@"clientWidth"] = [JSValue valueWithDouble:size.width
//                                               inContext:context];
//         body[@"clientHeight"] = [JSValue valueWithDouble:size.height
//                                               inContext:context];
//     }
//     if (@available(iOS 11.0, *)) {
//         body[@"windowPaddingTop"] = [JSValue valueWithDouble:[UIApplication sharedApplication].windows.firstObject.safeAreaInsets.top * [UIScreen mainScreen].scale
//                                                       inContext:context];
//         body[@"windowPaddingBottom"] = [JSValue valueWithDouble:[UIApplication sharedApplication].windows.firstObject.safeAreaInsets.bottom * [UIScreen mainScreen].scale
//                                                       inContext:context];
//     } else { }
//     document[@"body"] = body;
//     context.globalObject[@"disableMPProxy"] = @(YES);
//     context.globalObject[@"document"] = document;
//     context.globalObject[@"devicePixelRatio"] = [JSValue valueWithDouble:[UIScreen mainScreen].scale
//                                                                inContext:context];
