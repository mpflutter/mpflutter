part of './mp_flutter_runtime.dart';

abstract class MPDataReceiver {
  NavigatorState? getNavigator();
  BuildContext? getContext();
  void didReceivedFrameData(Map message);
}

class MPEngine {
  bool _started = false;
  bool get started => _started;
  final BuildContext flutterContext;
  final Map<int, MPDataReceiver> _managedViews = {};
  String? _jsCode;
  final List<String> _messageQueue = [];
  _MPDebugger? _debugger;
  _MPKReader? _mpkReader;
  late _JSContext _jsContext;
  late _MPJS _mpjs;
  late _MPComponentFactory _componentFactory;
  late _MPRouter _router;
  late _TextMeasurer _textMeasurer;
  late _DrawableStore _drawableStore;

  MPEngine({required this.flutterContext}) {
    _componentFactory = _MPComponentFactory(engine: this);
    _router = _MPRouter(engine: this);
    _textMeasurer = _TextMeasurer(engine: this);
    _drawableStore = _DrawableStore(engine: this);
    _jsContext = _JSContext();
    _mpjs = _MPJS(engine: this);
  }

  void initWithJSCode(String jsCode) {
    _jsCode = jsCode;
  }

  void initWithDebuggerServerAddr(String debuggerServerAddr) {
    _debugger = _MPDebugger(engine: this, serverAddr: debuggerServerAddr);
  }

  void initWithMpkData(Uint8List mpkData) {
    _mpkReader = _MPKReader(mpkData);
    Uint8List? mainDataJSData = _mpkReader?.dataWithFilePath('main.dart.js');
    if (mainDataJSData != null) {
      _jsCode = utf8.decode(mainDataJSData);
    }
  }

  Future start() async {
    if (_started) return;
    if (_jsCode == null && _debugger == null) return;
    await _jsContext.createContext();
    await _setupJSContextEventChannel();
    await _MPJS.install(_jsContext);
    await _JSDeviceInfo.install(_jsContext, flutterContext);
    await _JSWXCompat.install(_jsContext);
    await _JSNetworkHttp.install(_jsContext);
    await _JSStorage.install(_jsContext);
    if (_jsCode != null) {
      await _jsContext.evaluateScript(_jsCode!);
    } else if (_debugger != null) {
      _debugger!.start();
    }
    Future.delayed(Duration(seconds: 5)).then((value) {
      _jsContext.evaluateScript('console.log(wx.getStorageSync("sss"));');
    });
    _started = true;
  }

  void stop() {}

  Future _setupJSContextEventChannel() async {
    _jsContext.addMessageListener((message, type) {
      if (type == '\$engine') {
        _didReceivedMessage(message);
      }
    });
    await _jsContext.evaluateScript('let self = globalThis');
    await _jsContext.evaluateScript('''
    globalThis.engineScope = {
      onMessage: function(message) {
        globalThis.postMessage(message, '\$engine');
      },
    };
    globalThis.onMessage = function(message, type) {
      if (type == '\$engine') {
        globalThis.engineScope.postMessage(message);
      }
    }
    ''');
  }

  void _didReceivedMessage(String message) {
    final decodedMessage = json.decode(message) as Map;
    String type = decodedMessage['type'];
    if (decodedMessage['message'] == null) return;
    switch (type) {
      case 'frame_data':
        _didReceivedFrameData(decodedMessage['message']);
        break;
      case 'diff_data':
        _didReceivedDiffData(decodedMessage['message']);
        break;
      case 'element_gc':
        _didReceivedElementGC(decodedMessage['message']);
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
      case 'mpjs':
        _mpjs._didReceivedMessage(decodedMessage['message']);
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

  void _didReceivedElementGC(List data) {
    for (final item in data) {
      if (item is int) {
        _componentFactory._cacheViews.remove(item);
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
    } else {
      _jsContext.postMessage(message, '\$engine');
    }
  }
}
