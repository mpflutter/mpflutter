part of '../../mp_flutter_runtime.dart';

class MPPlatformView extends ComponentView {
  static final Map<String, Completer> _invokeMethodCallback = {};

  static void _didReceivedPlatformViewMessage(Map data, MPEngine engine) async {
    String? event = data['event'];
    if (event == 'methodCall') {
      int? hashCode = data['hashCode'];
      if (hashCode != null) {
        final target = engine._componentFactory._cacheViews[hashCode]?.widget;
        if (target is MPPlatformView) {
          final result = await target.onMethodCall(
            data['method'],
            data['params'],
          );
          if (data['requireResult'] == true) {
            engine._sendMessage({
              'type': 'platform_view',
              'message': {
                'event': 'methodCallCallback',
                'seqId': data['seqId'],
                'result': result,
              },
            });
          }
        }
      }
    } else if (event == 'methodCallCallback') {
      String? seqId = data['seqId'];
      if (seqId != null) {
        _invokeMethodCallback[seqId]?.complete(data['result']);
        _invokeMethodCallback.remove(seqId);
      }
    }
  }

  MPPlatformView({
    Key? key,
    Map? data,
    Map? parentData,
    required _MPComponentFactory componentFactory,
  }) : super(
            key: key,
            data: data,
            parentData: parentData,
            componentFactory: componentFactory);

  Future onMethodCall(String method, dynamic params) async {
    return null;
  }

  void invokeMethod(String method, dynamic params) {
    if (dataHashCode == null) return;
    final engine = componentFactory.engine;
    final seqId = Random().nextDouble().toString();
    engine._sendMessage({
      'type': 'platform_view',
      'message': {
        'event': 'methodCall',
        'hashCode': dataHashCode,
        'method': method,
        'params': params,
        'seqId': seqId,
      },
    });
  }

  Future invokeMethodWithResult(String method, dynamic params) async {
    if (dataHashCode == null) return;
    final engine = componentFactory.engine;
    final seqId = Random().nextDouble().toString();
    final completer = Completer();
    _invokeMethodCallback[seqId] = completer;
    engine._sendMessage({
      'type': 'platform_view',
      'message': {
        'event': 'methodCall',
        'hashCode': dataHashCode,
        'method': method,
        'params': params,
        'seqId': seqId,
        'requireResult': true,
      },
    });
    return completer.future;
  }

  @override
  Widget builder(BuildContext context) {
    return const SizedBox();
  }
}
