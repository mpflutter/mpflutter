import 'dart:js' as js;
import 'dart:typed_data';
import 'package:mpflutter_core/mpjs/mpjs.dart';

class Context extends JSObject implements IContext {
  static final shared = Context();
  static Map<String, Function> functionMap = {};
  static Map<String, int> functionArgsCount = {};

  Context() : super(js.context);

  Function createFunctionArgN(Function dartFunction) {
    final argCount = dartFunction.runtimeType.toString().contains("() =>")
        ? 0
        : dartFunction.runtimeType.toString().split("=>")[0].split(",").length;
    if (argCount == 0) {
      return createFunctionArg0(dartFunction);
    } else if (argCount == 1) {
      return createFunctionArg1(dartFunction);
    } else if (argCount == 2) {
      return createFunctionArg2(dartFunction);
    } else if (argCount == 3) {
      return createFunctionArg3(dartFunction);
    } else if (argCount == 4) {
      return createFunctionArg4(dartFunction);
    } else {
      return dartFunction;
    }
  }

  Function createFunctionArg0(Function dartFunction) {
    final funcId = dartFunction.hashCode.toString();
    Context.functionMap[funcId] ??= () {
      return JSObject.transformToBrowserJSObject(dartFunction());
    };
    Context.functionArgsCount[funcId] = 0;
    return Context.functionMap[funcId]!;
  }

  Function createFunctionArg1(Function dartFunction) {
    final funcId = dartFunction.hashCode.toString();
    Context.functionMap[funcId] ??= (arg0) {
      return JSObject.transformToBrowserJSObject(
          dartFunction(JSObject.transformToMPJSObject(arg0)));
    };
    Context.functionArgsCount[funcId] = 1;
    return Context.functionMap[funcId]!;
  }

  Function createFunctionArg2(Function dartFunction) {
    final funcId = dartFunction.hashCode.toString();
    Context.functionMap[funcId] ??= (arg0, arg1) {
      return JSObject.transformToBrowserJSObject(dartFunction(
        JSObject.transformToMPJSObject(arg0),
        JSObject.transformToMPJSObject(arg1),
      ));
    };
    Context.functionArgsCount[funcId] = 2;
    return Context.functionMap[funcId]!;
  }

  Function createFunctionArg3(Function dartFunction) {
    final funcId = dartFunction.hashCode.toString();
    Context.functionMap[funcId] ??= (arg0, arg1, arg2) {
      return JSObject.transformToBrowserJSObject(dartFunction(
        JSObject.transformToMPJSObject(arg0),
        JSObject.transformToMPJSObject(arg1),
        JSObject.transformToMPJSObject(arg2),
      ));
    };
    Context.functionArgsCount[funcId] = 3;
    return Context.functionMap[funcId]!;
  }

  Function createFunctionArg4(Function dartFunction) {
    final funcId = dartFunction.hashCode.toString();
    Context.functionMap[funcId] ??= (arg0, arg1, arg2, arg3) {
      return JSObject.transformToBrowserJSObject(dartFunction(
        JSObject.transformToMPJSObject(arg0),
        JSObject.transformToMPJSObject(arg1),
        JSObject.transformToMPJSObject(arg2),
        JSObject.transformToMPJSObject(arg3),
      ));
    };
    Context.functionArgsCount[funcId] = 4;
    return Context.functionMap[funcId]!;
  }

  Uint8List convertArrayBufferToUint8List(JSObject value) {
    final plainList = (js.context['Array'] as js.JsObject).callMethod('from', [
      js.JsObject(js.context['Uint8Array'], [value.jsObject])
    ]) as js.JsArray;
    List<int> plainDartList = [];
    plainList.asMap().forEach((key, value) {
      plainDartList.add(value);
    });
    return Uint8List.fromList(plainDartList);
  }

  JSObject newArrayBufferFromUint8List(Uint8List value) {
    final uint8Array = js.JsObject(
        js.context["Uint8Array"], [new js.JsArray.from(value.toList())]);
    final ab = uint8Array["buffer"];
    return JSObject(ab);
  }
}

class JSObject implements IJSObject {
  final js.JsObject jsObject;

  JSObject(dynamic arg)
      : this.jsObject = arg is js.JsObject
            ? arg
            : js.JsObject((() {
                var clazz = js.context[arg];
                if (clazz == null && js.context["wx"] != null) {
                  clazz = js.context["wx"][arg];
                }
                if (clazz == null) {
                  throw arg + " constructor not found!";
                }
                return clazz;
              })());

  static dynamic transformToMPJSObject(dynamic obj) {
    if (obj is js.JsArray) {
      return JSArray(obj);
    } else if (obj is js.JsFunction) {
      return JSFunction(obj);
    } else if (obj is Function) {
      return obj;
    } else if (obj is js.JsObject) {
      return JSObject(obj);
    } else if (obj is String || obj is num || obj is bool) {
      return obj;
    } else {
      return null;
    }
  }

  static dynamic transformToBrowserJSObject(dynamic obj) {
    if (obj is Map) {
      return js.JsObject.jsify(obj.map(
          (key, value) => MapEntry(key, transformToBrowserJSObject(value))));
    } else if (obj is List) {
      return js.JsObject.jsify(
          obj.map((e) => transformToBrowserJSObject(e)).toList());
    } else if (obj is Function) {
      return Context.shared.createFunctionArgN(obj);
    } else if (obj is JSObject) {
      return obj.jsObject;
    } else {
      return obj;
    }
  }

  @override
  operator [](dynamic key) {
    final obj = this.jsObject[key];
    return transformToMPJSObject(obj);
  }

  @override
  void operator []=(dynamic key, value) {
    this.jsObject[key] = transformToBrowserJSObject(value);
  }

  dynamic callMethod(String method, [List<dynamic>? arguments]) {
    final result = this.jsObject.callMethod(
        method,
        arguments?.map((e) {
          return transformToBrowserJSObject(e);
        }).toList());
    return transformToMPJSObject(result);
  }
}

class JSArray extends JSObject implements IJSArray {
  JSArray(super.jsObject);

  void add(dynamic value) {
    this.jsObject.callMethod(
      "push",
      [JSObject.transformToBrowserJSObject(value)],
    );
  }

  void addAll(List<dynamic> value) {
    value.forEach((element) {
      add(element);
    });
  }
}

class JSFunction extends JSObject implements IJSFunction {
  JSFunction(super.jsObject);

  dynamic call([List<dynamic>? arguments]) {
    return (this.jsObject as js.JsFunction).apply(arguments?.map((e) {
          return JSObject.transformToBrowserJSObject(e);
        }).toList() ??
        []);
  }
}
