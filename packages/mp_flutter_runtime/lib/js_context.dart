part of './mp_flutter_runtime.dart';

class _JSContext {
  static const _methodChannel = MethodChannel(
    'com.mpflutter.mp_flutter_runtime.js_context',
  );

  static const _eventChannel = EventChannel(
    'com.mpflutter.mp_flutter_runtime.js_callback',
  );

  static Stream<dynamic>? _eventStream;

  static void onMessage(dynamic value) {
    print(value);
  }

  String? _contextRef;

  Future releaseContext() async {
    if (_contextRef != null) {
      await _methodChannel.invokeMethod<String>('releaseContext', _contextRef);
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

  Future setValue(String key, dynamic value) async {
    if (_contextRef == null) {
      throw "no context";
    }
    return await _methodChannel.invokeMethod('setValue', {
      "contextRef": _contextRef,
      "key": key,
      "value": value,
    });
  }
}
