import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:mpcore/mpkit/mpkit.dart';

import '../channel/channel_io.dart'
    if (dart.library.js) '../channel/channel_js.dart';

JsObject get context {
  return JsObject();
}

Future<dynamic> evalTemplate(String templateName, [List<dynamic>? args]) async {
  if (MPEnv.envHost() == MPEnvHostType.wechatMiniProgram) {
    return await context['wx']
        .callMethod('\$mpjs_template_$templateName', args);
  } else {
    return await context.callMethod('\$mpjs_template_$templateName', args);
  }
}

class JsBridgeInvoker {
  static final instance = JsBridgeInvoker();

  Map<String, Completer> handlers = {};

  Future makeRequest(String event, Map params) {
    final completer = Completer();
    final requestId = Random().nextDouble().toString();
    handlers[requestId] = completer;
    MPChannel.postMessage(
      json.encode({
        'type': 'mpjs',
        'flow': 'request',
        'message': {
          'event': event,
          'requestId': requestId,
          'params': params,
        },
      }),
      forLastConnection: true,
    );
    return completer.future;
  }

  void makeResponse(Map message) {
    if (!(message is Map)) return;
    if (message['requestId'] != null) {
      final String requestId = message['requestId'];
      handlers[requestId]
          ?.complete(JsObject.wrapBrowserObject(message['result']));
      handlers.remove(requestId);
    } else if (message['funcId'] != null) {
      final String funcId = message['funcId'];
      final func =
          JsObject.funcHandlers[int.tryParse(funcId.replaceFirst('func:', ''))];
      if (func is Function) {
        Function.apply(
          func,
          (message['arguments'] as List)
              .map((e) => JsObject.wrapBrowserObject(e))
              .toList(),
        );
      } else if (func is JsFunction) {
        func.call((message['arguments'] as List)
            .map((e) => JsObject.wrapBrowserObject(e))
            .toList());
      }
    }
  }
}

class JsObject {
  static Map<int, dynamic> funcHandlers = {};

  static dynamic wrapBrowserObject(dynamic obj) {
    if (obj is JsObject) {
      return obj;
    } else if (obj is String) {
      if (obj.startsWith('base64:')) {
        return base64.decode(obj.replaceFirst('base64:', ''));
      }
      return obj;
    } else if (obj is num) {
      return obj;
    } else if (obj is bool) {
      return obj;
    } else {
      try {
        if (obj['objectHandler'] is String) {
          return JsObject(objectHandler: obj['objectHandler']);
        }
        // ignore: empty_catches
      } catch (e) {}
      return obj;
    }
  }

  static dynamic toBrowserObject(dynamic obj) {
    if (obj is Function) {
      final funcId = obj.hashCode;
      funcHandlers[funcId] = obj;
      return 'func:${funcId}';
    } else if (obj is JsFunction) {
      final funcId = obj.originFunction.hashCode;
      funcHandlers[funcId] = obj;
      return 'func:${funcId}';
    } else if (obj is Uint8List) {
      final base64EncodedString = base64.encode(obj);
      return 'base64:${base64EncodedString}';
    } else if (obj is JsObject && obj.objectHandler != null) {
      return 'obj:${obj.objectHandler}';
    } else if (obj is Map) {
      return obj.map((key, value) => MapEntry(key, toBrowserObject(value)));
    } else if (obj is List) {
      return obj.map((e) => toBrowserObject(e)).toList();
    } else {
      try {
        return toBrowserObject(obj.toJson());
      } catch (e) {}
      return obj;
    }
  }

  final List<String> _callChain = [];
  final String? objectHandler;

  JsObject({this.objectHandler});

  JsObject operator [](Object property) {
    if (!(property is String)) return JsObject();
    return getProperty(property);
  }

  JsObject getProperty(String key) {
    final obj = JsObject(objectHandler: objectHandler);
    obj._callChain
      ..addAll(_callChain)
      ..add(key);
    return obj;
  }

  Future<bool> hasProperty(String key) async {
    final result = await JsBridgeInvoker.instance.makeRequest('hasProperty', {
      'callChain': _callChain,
      'objectHandler': objectHandler,
      'key': key,
    });
    if (result is bool) {
      return result;
    } else {
      return false;
    }
  }

  Future<void> deleteProperty(String key) {
    return JsBridgeInvoker.instance.makeRequest('deleteProperty', {
      'callChain': _callChain,
      'objectHandler': objectHandler,
      'key': key,
    });
  }

  Future<dynamic> callMethod(Object method, [List? args]) async {
    final trimedArgs = args?.map((e) {
      return toBrowserObject(e);
    }).toList();
    if (trimedArgs != null) {
      for (var i = trimedArgs.length - 1; i >= 0; i--) {
        if (trimedArgs[i] == null) {
          trimedArgs.removeLast();
        } else {
          break;
        }
      }
    }
    final result = await JsBridgeInvoker.instance.makeRequest('callMethod', {
      'objectHandler': objectHandler,
      'callChain': _callChain,
      'method': method,
      'args': trimedArgs,
    });
    return result;
  }

  Future<JsObject> newObject(String clazz, [List? args]) async {
    final trimedArgs = args?.map((e) {
      return toBrowserObject(e);
    }).toList();
    if (trimedArgs != null) {
      for (var i = trimedArgs.length - 1; i >= 0; i--) {
        if (trimedArgs[i] == null) {
          trimedArgs.removeLast();
        } else {
          break;
        }
      }
    }
    final result = await JsBridgeInvoker.instance.makeRequest('newObject', {
      'objectHandler': objectHandler,
      'callChain': _callChain,
      'clazz': clazz,
      'args': trimedArgs,
    });
    return result;
  }

  Future<T?> getPropertyValue<T>(dynamic key) async {
    var result = await JsBridgeInvoker.instance.makeRequest('getValue', {
      'objectHandler': objectHandler,
      'callChain': _callChain,
      'key': key,
    });
    if (result is List) {
      result = result.map((e) => JsObject.wrapBrowserObject(e)).toList() as T;
    } else if (result is Map) {
      result = result.map(
              (key, value) => MapEntry(key, JsObject.wrapBrowserObject(value)))
          as T;
    }
    if (T == dynamic || T == Object) {
      return result;
    } else if (result is T) {
      return result;
    } else {
      return null;
    }
  }

  Future<dynamic> setPropertyValue(dynamic key, dynamic value) async {
    final result = await JsBridgeInvoker.instance.makeRequest('setValue', {
      'objectHandler': objectHandler,
      'callChain': _callChain,
      'key': key,
      'value': toBrowserObject(value),
    });
    return result;
  }
}

class JsFunction {
  final Function originFunction;
  final List<dynamic Function(dynamic)?> converters;

  JsFunction(this.originFunction, this.converters);

  void call(List<dynamic> arguments) {
    final newArguments = <dynamic>[];
    arguments.asMap().forEach((key, value) {
      newArguments.add(converters[key]?.call(value) ?? value);
    });
    Function.apply(originFunction, newArguments);
  }
}
