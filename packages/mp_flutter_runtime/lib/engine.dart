part of './mp_flutter_runtime.dart';

abstract class MPDataReceiver {
  void didReceivedFrameData(Map message);
}

class MPEngine {
  bool _started = false;
  bool get started => _started;
  Map<int, MPDataReceiver> _managedViews = {};
  String? _jsCode;
  _JSContext? jsContext;
  List<String> _messageQueue = [];
  _MPDebugger? _debugger;
  late _MPRouter _router;

  MPEngine() {
    _router = _MPRouter(engine: this);
  }

  void initWithJSCode(String jsCode) {
    _jsCode = jsCode;
  }

  void initWithDebuggerServerAddr(String debuggerServerAddr) {
    _debugger = _MPDebugger(engine: this, serverAddr: debuggerServerAddr);
  }

  void initWithMpkData(Uint8List mpkData) {}

  void start() {
    if (_started) return;
    if (_jsCode == null && _debugger == null) return;
    if (_debugger != null) {
      _debugger!.start();
    }
    _started = true;
  }

  void stop() {}

  void _didReceivedMessage(String message) {
    final decodedMessage = json.decode(message) as Map;
    String type = decodedMessage['type'];
    switch (type) {
      case 'frame_data':
        _didReceivedFrameData(decodedMessage['message']);
        break;
      case 'route':
        _router._didReceivedRouteData(decodedMessage['message']);
        break;
      default:
    }
  }

  void _didReceivedFrameData(Map frameData) {
    int routeId = frameData['routeId'];
    MPDataReceiver? targetView = _managedViews[routeId];
    if (targetView != null) {
      targetView.didReceivedFrameData(frameData);
    }
  }

  void _addManageView(int viewId, MPDataReceiver view) {
    _managedViews[viewId] = view;
  }

  void _sendMessage(Map mapMessage) {
    String message = json.encode(mapMessage);
    if (_debugger != null) {
      _debugger!.sendMessage(message);
    }
  }
}
