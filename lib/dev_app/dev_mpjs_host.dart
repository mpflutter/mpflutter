import 'package:mpflutter_core/dev_app/dev_server.dart';

class _MPJSMethodList {
  static final newObject = "mpjs.newObject";
  static final valueOfObject = "mpjs.valueOfObject";
  static final setValueOfObject = "mpjs.setValueOfObject";
  static final callMethod = "mpjs.callMethod";
  static final applyFunction = "mpjs.applyFunction";
  static final callDartFunction = "mpjs.callDartFunction";
  static final returnCallDartFunctionResult =
      "mpjs.returnCallDartFunctionResult";
  static final plainValueOfObject = "mpjs.plainValueOfObject";
}

class DevMPJSHost {
  static final shared = DevMPJSHost();

  dynamic Function(String, String, List<dynamic>)? onCallDartFunction;

  DevMPJSHost() {
    IsolateDevServer.shared.eventListenner = (method, params) {
      if (method == _MPJSMethodList.callDartFunction) {
        final funcCallId = params["funcCallId"] as String;
        final funcRef = params["funcRef"] as String;
        final args = params["args"] as List<dynamic>;
        onCallDartFunction?.call(funcCallId, funcRef, args);
      }
    };
  }

  dynamic newObject(String clazz, List? arguments) {
    final result = IsolateDevServer.shared.invokeMethod(
      _MPJSMethodList.newObject,
      {
        "clazz": clazz,
        "arguments": arguments,
      },
    );
    return result;
  }

  dynamic valueOfObject(dynamic key, String objectRef) {
    final result = IsolateDevServer.shared.invokeMethod(
      _MPJSMethodList.valueOfObject,
      {
        "key": key,
        "objectRef": objectRef,
      },
    );
    return result;
  }

  dynamic plainValueOfObject(String objectRef) {
    final result = IsolateDevServer.shared.invokeMethod(
      _MPJSMethodList.plainValueOfObject,
      {
        "objectRef": objectRef,
      },
    );
    return result;
  }

  dynamic setValueOfObject(dynamic key, dynamic value, String objectRef) {
    final result = IsolateDevServer.shared.invokeMethod(
      _MPJSMethodList.setValueOfObject,
      {
        "key": key,
        "value": value,
        "objectRef": objectRef,
      },
    );
    return result;
  }

  dynamic callMethod(
      dynamic method, List<dynamic> arguments, String objectRef) {
    final result = IsolateDevServer.shared.invokeMethod(
      _MPJSMethodList.callMethod,
      {
        "method": method,
        "arguments": arguments,
        "objectRef": objectRef,
      },
    );
    return result;
  }

  dynamic applyFunction(
    String? thisRef,
    List<dynamic> arguments,
    String objectRef,
  ) {
    final result = IsolateDevServer.shared.invokeMethod(
      _MPJSMethodList.applyFunction,
      {
        "thisRef": thisRef,
        "arguments": arguments,
        "objectRef": objectRef,
      },
    );
    return result;
  }

  returnCallDartFunctionResult(String funcCallId, dynamic result) {
    IsolateDevServer.shared.invokeMethod(
      _MPJSMethodList.returnCallDartFunctionResult,
      {
        "funcCallId": funcCallId,
        "result": result,
      },
    );
  }
}
