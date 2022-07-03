part of '../mp_flutter_runtime.dart';

class _MPPlatformChannelIO {
  static final responseCallbacks = <String, Completer>{};
  static final eventChannelStreamSubscriptions = <String, StreamSubscription>{};

  final MPEngine engine;
  final pluginInstances = <String, dynamic>{};

  _MPPlatformChannelIO({required this.engine}) {
    MPPluginRegister.registedChannels.forEach((key, value) {
      final instance = value();
      if (instance is MPMethodChannel) {
        instance
          ..engine = engine
          ..channelName = key;
      } else if (instance is MPEventChannel) {
        instance
          ..engine = engine
          ..channelName = key;
      }
      pluginInstances[key] = instance;
    });
  }

  void _didReceivedMessage(Map data) async {
    String? event = data['event'];
    if (event == null) return;
    switch (event) {
      case 'invokeMethod':
        String method = data["method"];
        String? beInvokeMethod = data["beInvokeMethod"];
        dynamic beInvokeParams = data["beInvokeParams"];
        dynamic beInvokeData = data["beInvokeData"];
        dynamic seqId = data["seqId"];
        dynamic instance = pluginInstances[method];
        if (instance is MPMethodChannel && beInvokeMethod != null) {
          try {
            final result = await instance.onMethodCall(
              beInvokeMethod,
              beInvokeParams,
            );
            engine._sendMessage({
              'type': 'platform_channel',
              'message': {
                'event': 'callbackResult',
                'result': result,
                'seqId': seqId,
              },
            });
          } catch (e) {
            engine._sendMessage({
              'type': 'platform_channel',
              'message': {
                'event': 'callbackResult',
                'result': 'ERROR: $e',
                'seqId': seqId,
              },
            });
          }
        } else if (instance is MPEventChannel) {
          if (beInvokeMethod == 'listen') {
            instance.onListen(beInvokeParams, (data) {
              engine._sendMessage({
                'type': 'platform_channel',
                'message': {
                  'event': 'callbackEventSink',
                  'method': method,
                  'result': data,
                  'seqId': seqId,
                },
              });
            });
          } else if (beInvokeMethod == 'cancel') {
            instance.onCancel(beInvokeParams);
          }
        } else {
          try {
            final codec = (() {
              if (method == 'flutter/system' ||
                  method == 'flutter/keyevent' ||
                  method == 'flutter/platform') {
                return const JSONMethodCodec();
              }
              return const StandardMethodCodec();
            })();
            dynamic result;
            if (beInvokeMethod != null) {
              if (beInvokeMethod == "listen") {
                eventChannelStreamSubscriptions[method] =
                    EventChannel(method, codec)
                        .receiveBroadcastStream()
                        .listen((data) {
                  engine._sendMessage({
                    'type': 'platform_channel',
                    'message': {
                      'event': 'callbackEventSink',
                      'method': method,
                      'result': data,
                      'seqId': seqId,
                    },
                  });
                });
              } else if (beInvokeMethod == "cancel") {
                eventChannelStreamSubscriptions[method]?.cancel();
              }
              result = await MethodChannel(method, codec).invokeMethod(
                beInvokeMethod,
                beInvokeParams,
              );
            } else {
              result = await BasicMessageChannel(
                      method, const StandardMessageCodec())
                  .send(
                beInvokeData,
              );
            }
            engine._sendMessage({
              'type': 'platform_channel',
              'message': {
                'event': 'callbackResult',
                'result': result,
                'seqId': seqId,
              },
            });
          } catch (e) {
            engine._sendMessage({
              'type': 'platform_channel',
              'message': {
                'event': 'callbackResult',
                'result': 'ERROR: $e',
                'seqId': seqId,
              },
            });
          }
        }
        break;
      case 'callbackResult':
        final seqId = data["seqId"];
        if (seqId == null) {
          return;
        }
        dynamic result = data["result"];
        responseCallbacks[seqId]?.complete(result);
        responseCallbacks.remove(seqId);
        break;
      default:
    }
  }
}
