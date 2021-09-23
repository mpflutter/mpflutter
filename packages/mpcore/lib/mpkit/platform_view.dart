part of 'mpkit.dart';

class MPPlatformViewController {
  int? targetHashCode;

  void onMethodCall(String method, Map? params) {}

  void invokeMethod(String method, {Map? params}) {
    if (targetHashCode != null) {
      MPChannel.postMessage(json.encode({
        'type': 'platform_view',
        'message': {
          'event': 'methodCall',
          'hashCode': targetHashCode,
          'method': method,
          'params': params,
        }
      }));
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
