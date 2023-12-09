import 'dart:typed_data';

import 'package:mpflutter_core/dev_app/dev_mpjs_host.dart';
import 'package:mpflutter_core/dev_app/dev_server.dart';
import 'package:mpflutter_core/mpjs/mpjs.dart';

class Context extends JSObject implements IContext {
  static Map<String, Function> functionMap = {};
  static Map<String, int> functionArgsCount = {};

  Context() : super("ref:globalThis");

  static void _installFunctionCallbackListenner() {
    if (DevMPJSHost.shared.onCallDartFunction == null) {
      DevMPJSHost.shared.onCallDartFunction = (funcCallId, funcRef, args) {
        final func = functionMap[funcRef];
        final argsCount = functionArgsCount[funcRef] ?? args.length;
        dynamic result;
        if (func != null) {
          if (argsCount == 0) {
            result = func();
          } else if (argsCount == 1) {
            result = func(JSObject.transformToMPJSObject(args[0]));
          } else if (argsCount == 2) {
            result = func(
              JSObject.transformToMPJSObject(args[0]),
              JSObject.transformToMPJSObject(args[1]),
            );
          } else if (argsCount == 3) {
            result = func(
              JSObject.transformToMPJSObject(args[0]),
              JSObject.transformToMPJSObject(args[1]),
              JSObject.transformToMPJSObject(args[2]),
            );
          } else if (argsCount == 4) {
            result = func(
              JSObject.transformToMPJSObject(args[0]),
              JSObject.transformToMPJSObject(args[1]),
              JSObject.transformToMPJSObject(args[2]),
              JSObject.transformToMPJSObject(args[3]),
            );
          }
          DevMPJSHost.shared.returnCallDartFunctionResult(
            funcCallId,
            JSObject.transformToBrowserJSObject(result),
          );
        }
      };
    }
  }

  static Function createFunctionArgN(Function dartFunction) {
    _installFunctionCallbackListenner();
    final funcId = "func:" + dartFunction.hashCode.toString();
    functionMap[funcId] = dartFunction;
    return dartFunction;
  }

  Function createFunctionArg0(Function dartFunction) {
    _installFunctionCallbackListenner();
    final funcId = "func:" + dartFunction.hashCode.toString();
    functionMap[funcId] = dartFunction;
    functionArgsCount[funcId] = 0;
    return dartFunction;
  }

  Function createFunctionArg1(Function dartFunction) {
    _installFunctionCallbackListenner();
    final funcId = "func:" + dartFunction.hashCode.toString();
    functionMap[funcId] = dartFunction;
    functionArgsCount[funcId] = 1;
    return dartFunction;
  }

  Function createFunctionArg2(Function dartFunction) {
    _installFunctionCallbackListenner();
    final funcId = "func:" + dartFunction.hashCode.toString();
    functionMap[funcId] = dartFunction;
    functionArgsCount[funcId] = 2;
    return dartFunction;
  }

  Function createFunctionArg3(Function dartFunction) {
    _installFunctionCallbackListenner();
    final funcId = "func:" + dartFunction.hashCode.toString();
    functionMap[funcId] = dartFunction;
    functionArgsCount[funcId] = 3;
    return dartFunction;
  }

  Function createFunctionArg4(Function dartFunction) {
    _installFunctionCallbackListenner();
    final funcId = "func:" + dartFunction.hashCode.toString();
    functionMap[funcId] = dartFunction;
    functionArgsCount[funcId] = 4;
    return dartFunction;
  }

  Uint8List convertArrayBufferToUint8List(JSObject value) {
    final contextArray = context['Array'] as JSObject;
    final plainList = contextArray.callMethod('from', [
      JSObject('Uint8Array', [value])
    ]) as JSArray;
    return Uint8List.fromList(plainList.value().cast());
  }

  JSObject newArrayBufferFromUint8List(Uint8List value) {
    final uint8Array = JSObject('Uint8Array', [value.toList()]);
    final ab = uint8Array["buffer"];
    return ab;
  }
}

class JSObject implements IJSObject {
  late final String objectRef;

  JSObject(String refOrClazz, [List? arguments]) {
    if (refOrClazz.contains("ref:")) {
      this.objectRef = refOrClazz;
    } else {
      final valueORObjectRef = DevMPJSHost.shared.newObject(
        refOrClazz,
        arguments?.map((e) => transformToBrowserJSObject(e)).toList() ?? [],
      );
      if (valueORObjectRef is Map && valueORObjectRef["clazz"] == "object") {
        this.objectRef = valueORObjectRef["ref"];
      } else {
        throw Error.safeToString("Fail to create $refOrClazz object");
      }
    }
  }

  static dynamic transformToMPJSObject(dynamic obj) {
    if (obj is Map && obj["clazz"] == "object") {
      return JSObject(obj["ref"]);
    } else if (obj is Map && obj["clazz"] == "array") {
      return JSArray(obj["ref"]);
    } else if (obj is Map && obj["clazz"] == "function") {
      return JSFunction(obj["ref"]);
    } else {
      return obj;
    }
  }

  static dynamic transformToBrowserJSObject(dynamic obj) {
    if (obj is Map) {
      return obj.map(
          (key, value) => MapEntry(key, transformToBrowserJSObject(value)));
    } else if (obj is List) {
      return obj.map((e) => transformToBrowserJSObject(e)).toList();
    } else {
      if (obj is Function) {
        if (Context.functionMap[obj.hashCode.toString()] == null) {
          Context.createFunctionArgN(obj);
        }
        return {
          "clazz": "function",
          "ref": "func:" + obj.hashCode.toString(),
        };
      }
      if (obj is JSObject) {
        return obj.objectRef;
      }
      return obj;
    }
  }

  @override
  operator [](dynamic key) {
    final valueORObjectRef = DevMPJSHost.shared.valueOfObject(key, objectRef);
    if (valueORObjectRef is Map) {
      return transformToMPJSObject(valueORObjectRef);
    }
    return valueORObjectRef;
  }

  @override
  void operator []=(dynamic key, value) {
    DevMPJSHost.shared.setValueOfObject(
      key,
      transformToBrowserJSObject(value),
      objectRef,
    );
  }

  dynamic callMethod(String method, [List<dynamic>? arguments]) {
    final result = DevMPJSHost.shared.callMethod(
      method,
      arguments?.map((e) => transformToBrowserJSObject(e)).toList() ?? [],
      objectRef,
    );
    return transformToMPJSObject(result);
  }
}

class JSArray extends JSObject implements IJSArray {
  JSArray(super.jsObject);

  void add(dynamic value) {
    DevMPJSHost.shared.callMethod(
      "push",
      [JSObject.transformToBrowserJSObject(value)],
      objectRef,
    );
  }

  void addAll(List<dynamic> value) {
    value.forEach((element) {
      add(element);
    });
  }

  List<dynamic> value() {
    return DevMPJSHost.shared.plainValueOfObject(objectRef);
  }
}

class JSFunction extends JSObject implements IJSFunction {
  JSFunction(super.jsObject);

  dynamic call([List<dynamic>? arguments]) {
    final result = DevMPJSHost.shared.applyFunction(
      null,
      arguments?.map((e) => JSObject.transformToBrowserJSObject(e)).toList() ??
          [],
      objectRef,
    );
    return JSObject.transformToMPJSObject(result);
  }
}
