part of '../mp_flutter_runtime.dart';

class MPEventChannel extends EventChannel {
  MPEngine? engine;
  String? channelName;

  MPEventChannel(String name,
      [codec = const StandardMethodCodec(), BinaryMessenger? binaryMessenger])
      : super(name, codec, binaryMessenger);

  void onListen(dynamic params, Function(dynamic data) eventSink) {}
  void onCancel(dynamic params) {}
}
