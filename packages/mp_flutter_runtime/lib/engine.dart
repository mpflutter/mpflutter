part of './mp_flutter_runtime.dart';

abstract class MPDataReceiver {
  NavigatorState? getNavigator();
  BuildContext? getContext();
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
  late _MPComponentFactory _componentFactory;
  late _MPRouter _router;
  late _TextMeasurer _textMeasurer;
  late _DrawableStore _drawableStore;

  MPEngine() {
    _componentFactory = _MPComponentFactory(engine: this);
    _router = _MPRouter(engine: this);
    _textMeasurer = _TextMeasurer(engine: this);
    _drawableStore = _DrawableStore(engine: this);
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
      case 'diff_data':
        _didReceivedDiffData(decodedMessage['message']);
        break;
      case 'decode_drawable':
        _drawableStore.decodeDrawable(decodedMessage['message']);
        break;
      case 'route':
        _router._didReceivedRouteData(decodedMessage['message']);
        break;
      case 'custom_paint':
        _CustomPaint._didReceivedCustomPaintMessage(
            decodedMessage['message'], this);
        break;
      case 'rich_text':
        _textMeasurer._didReceivedDoMeasureData(decodedMessage['message']);
        break;
      case 'action:web_dialogs':
        _WebDialogs.didReceivedWebDialogsMessage(
            decodedMessage['message'], this);
        break;
      case 'platform_view':
        _MPPlatformView._didReceivedPlatformViewMessage(
            decodedMessage['message'], this);
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

  void _didReceivedDiffData(Map frameData) {
    List diffs = frameData['diffs'];
    for (final data in diffs) {
      if (data is Map) {
        int? hashCode = data['hashCode'];
        if (hashCode != null) {
          _componentFactory._cacheViews[hashCode]?.updateData(data);
        }
      }
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
