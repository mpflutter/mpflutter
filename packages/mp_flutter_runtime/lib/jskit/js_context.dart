part of '../mp_flutter_runtime.dart';

class _JSContext {
  static const _methodChannel = MethodChannel(
    'com.mpflutter.mp_flutter_runtime.js_context',
  );

  static const _eventChannel = EventChannel(
    'com.mpflutter.mp_flutter_runtime.js_callback',
  );

  static Stream<dynamic>? _eventStream;

  static final Map<String, _JSContext> _refs = {};

  static void onMessage(Map value) {
    final contextRef = value['contextRef'];
    final message = value['data'] as String;
    final type = value['type'] as String?;
    final context = _refs[contextRef];
    if (context != null) {
      for (final messageListener in context._messageListeners) {
        messageListener(message, type);
      }
    }
  }

  final List<Function(String message, String? type)> _messageListeners = [];

  String? _contextRef;

  Future releaseContext() async {
    if (_contextRef != null) {
      await _methodChannel.invokeMethod<String>('releaseContext', _contextRef);
      _refs.remove(_contextRef);
      _contextRef = null;
    }
  }

  Future createContext() async {
    if (_eventStream == null) {
      _eventStream = _eventChannel.receiveBroadcastStream();
      _eventStream!.listen((event) {
        onMessage(event);
      });
    }
    _contextRef ??= await _methodChannel.invokeMethod<String>('createContext');
    _refs[_contextRef!] = this;
    await _installFeatures();
  }

  Future _installFeatures() async {
    await _JSConsole.install(this);
  }

  Future evaluateScript(String script) async {
    if (_contextRef == null) {
      throw "no context";
    }
    return await _methodChannel.invokeMethod('evaluateScript', {
      "contextRef": _contextRef,
      "script": script,
    });
  }

  Future postMessage(String message, [String? type]) async {
    if (_contextRef == null) {
      throw "no context";
    }
    return await _methodChannel.invokeMethod('invokeFunc', {
      "contextRef": _contextRef,
      'func': 'onMessage',
      "args": [message, type],
    });
  }

  Future invokeJSFunc(String func, List args) async {
    if (_contextRef == null) {
      throw "no context";
    }
    return await _methodChannel.invokeMethod('invokeFunc', {
      "contextRef": _contextRef,
      'func': func,
      "args": args,
    });
  }

  Future invokeMPJSFunc(Map message) async {
    if (_contextRef == null) {
      throw "no context";
    }
    return await _methodChannel.invokeMethod('invokeMPJSFunc', {
      "contextRef": _contextRef,
      "message": message,
    });
  }

  void addMessageListener(Function(String message, String? type) listener) {
    _messageListeners.add(listener);
  }

  void removeMessageListener(Function(String message, String? type) listener) {
    _messageListeners.remove(listener);
  }
}
