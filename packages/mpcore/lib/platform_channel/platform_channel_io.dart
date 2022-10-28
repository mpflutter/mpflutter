part of '../mpcore.dart';

class _PlatformChannelIO {
  static final _responseCallbacks = <int, ui.PlatformMessageResponseCallback>{};

  static void pluginMessageCallHandler(
    String method,
    ByteData? data,
    ui.PlatformMessageResponseCallback? callback,
  ) {
    MethodCall? methodMessage;
    if (data != null) {
      try {
        methodMessage = StandardMethodCodec().decodeMethodCall(data);
      } catch (e) {
        methodMessage = JSONMethodCodec().decodeMethodCall(data);
      }
    }
    final seqId = _generateSeqId();
    if (callback != null) {
      _responseCallbacks[seqId] = callback;
    }
    MPChannel.postMessage(json.encode({
      'type': 'platform_channel',
      'message': {
        'event': 'invokeMethod',
        'method': method,
        'beInvokeMethod': methodMessage?.method,
        'beInvokeParams': methodMessage?.arguments,
        'seqId': seqId,
      },
    }));
  }

  static void onPlatformChannelTrigger(Map message) async {
    try {
      if (message['event'] == 'invokeMethod') {
        String method = message['method'] ?? '';
        String beInvokeMethod = message['beInvokeMethod'] ?? '';
        dynamic beInvokeParams = message['beInvokeParams'];
        dynamic seqId = message['seqId'];
        await ServicesBinding.instance?.defaultBinaryMessenger
            .handlePlatformMessage(
          method,
          StandardMethodCodec().encodeMethodCall(
            MethodCall(beInvokeMethod, beInvokeParams),
          ),
          (byteData) {
            if (byteData != null) {
              try {
                final result = StandardMethodCodec().decodeEnvelope(byteData);
                MPChannel.postMessage(json.encode({
                  'type': 'platform_channel',
                  'message': {
                    'event': 'callbackResult',
                    'seqId': seqId,
                    'result': result,
                  },
                }));
              } catch (e) {
                MPChannel.postMessage(json.encode({
                  'type': 'platform_channel',
                  'message': {
                    'event': 'callbackResult',
                    'seqId': seqId,
                    'result': 'ERROR: ' + e.toString(),
                  },
                }));
              }
            }
          },
        );
      } else if (message['event'] == 'callbackResult') {
        int seqId = message['seqId'];
        dynamic result = message['result'];
        final callback = _responseCallbacks[seqId];
        if (callback != null) {
          if (result == 'NOTIMPLEMENTED' ||
              (result is String && result.startsWith('ERROR:'))) {
            callback(
              StandardMethodCodec().encodeErrorEnvelope(
                code: result,
                message: result,
              ),
            );
          } else {
            callback(
              StandardMethodCodec().encodeSuccessEnvelope(result),
            );
          }
          _responseCallbacks.remove(seqId);
        }
      } else if (message['event'] == 'callbackEventSink') {
        String method = message['method'];
        dynamic result = message['result'];
        final _ = ServicesBinding.instance?.defaultBinaryMessenger
            .handlePlatformMessage(method,
                StandardMethodCodec().encodeSuccessEnvelope(result), (_) {});
      }
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  static int _seqId = 0;

  static int _generateSeqId() {
    _seqId++;
    return _seqId;
  }
}
