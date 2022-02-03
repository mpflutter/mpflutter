part of '../mp_flutter_runtime.dart';

class MPMethodChannel extends MethodChannel {
  MPEngine? engine;
  String? channelName;

  MPMethodChannel(String name,
      [codec = const StandardMethodCodec(), BinaryMessenger? binaryMessenger])
      : super(name, codec, binaryMessenger);

  Future? onMethodCall(String method, dynamic params) async {
    throw 'NOT IMPLEMENTED';
  }

  @override
  Future<T?> invokeMethod<T>(String method, [dynamic arguments]) async {
    if (engine == null) throw 'no engine';
    final seqId = Random().nextDouble().toString();
    engine!._sendMessage({
      'type': 'platform_channel',
      'message': {
        'event': 'invokeMethod',
        'method': channelName,
        'beInvokeMethod': method,
        'beInvokeParams': arguments,
        'seqId': seqId,
      },
    });
    final completer = Completer<T?>();
    _MPPlatformChannelIO.responseCallbacks[seqId] = completer;
    return completer.future;
  }
}
