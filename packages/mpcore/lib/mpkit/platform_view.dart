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

class MPPlatformViewWithIntrinsicContentSize extends StatefulWidget {
  final WidgetBuilder builder;

  MPPlatformViewWithIntrinsicContentSize({required this.builder});

  @override
  State<MPPlatformViewWithIntrinsicContentSize> createState() =>
      MPPlatformViewWithIntrinsicContentSizeState();
}

class MPPlatformViewWithIntrinsicContentSizeState
    extends State<MPPlatformViewWithIntrinsicContentSize> {
  Size? _size;

  Size? get size => _size;

  set size(Size? size) {
    _size = size;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        minWidth: 1.0,
        minHeight: 1.0,
      ),
      child: widget.builder(context),
    );
  }
}

class MPPlatformView extends StatelessWidget {
  final MPPlatformViewController? controller;
  final String viewType;
  final Map<String, dynamic> viewAttributes;
  final Widget? child;
  final List<Widget>? children;
  final Future? Function(String method, Map? params)? onMethodCall;

  const MPPlatformView({
    required this.viewType,
    this.viewAttributes = const {},
    this.controller,
    this.child,
    this.children,
    this.onMethodCall,
  });

  @override
  Widget build(BuildContext context) {
    final sizeFromIntrinsicContentSize = context
        .findAncestorStateOfType<MPPlatformViewWithIntrinsicContentSizeState>();
    if (sizeFromIntrinsicContentSize != null &&
        sizeFromIntrinsicContentSize.size != null) {
      return Container(
        width: sizeFromIntrinsicContentSize.size!.width,
        height: sizeFromIntrinsicContentSize.size!.height,
        child: children != null
            ? Stack(
                children:
                    children!.map((e) => Positioned.fill(child: e)).toList())
            : child,
      );
    } else if (children != null) {
      return Stack(
        children: children!.map((e) => Positioned.fill(child: e)).toList(),
      );
    } else {
      return child ?? Container();
    }
  }
}
