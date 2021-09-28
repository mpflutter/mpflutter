part of 'mpkit.dart';

class MPPlatformViewController {
  static final Map<String, Completer> _invokeMethodCompleter = {};

  static void handleInvokeMethodCallback(String seqId, dynamic result) {
    if (_invokeMethodCompleter.containsKey(seqId)) {
      _invokeMethodCompleter[seqId]!.complete(result);
      _invokeMethodCompleter.remove(seqId);
    }
  }

  int? targetHashCode;

  Future? onMethodCall(String method, Map? params) {}

  Future? invokeMethod(String method, {Map? params, bool? requireResult}) {
    if (targetHashCode != null) {
      final seqId = '${targetHashCode}_${math.Random().nextDouble()}';
      Completer? completer;
      if (requireResult == true) {
        completer = Completer();
        _invokeMethodCompleter[seqId] = completer;
      }
      MPChannel.postMessage(json.encode({
        'type': 'platform_view',
        'message': {
          'event': 'methodCall',
          'hashCode': targetHashCode,
          'method': method,
          'params': params,
          'seqId': seqId,
          'requireResult': requireResult,
        }
      }));
      return completer?.future;
    }
  }
}

class MPPlatformView extends StatelessWidget {
  final MPPlatformViewController? controller;
  final String viewType;
  final Map<String, dynamic> viewAttributes;
  final Widget? child;

  MPPlatformView({
    required this.viewType,
    this.viewAttributes = const {},
    this.controller,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return child ?? Container();
  }
}
