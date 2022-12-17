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
  _MPDebugger? debugger;
  _MPKReader? _mpkReader;
  late _JSContext _jsContext;
  late _MPJS _mpjs;
  late _MPComponentFactory _componentFactory;
  late _MPRouter _router;
  late _TextMeasurer _textMeasurer;
  late _DrawableStore _drawableStore;
  late _MPPlatformChannelIO _platformChannelIO;
  var provider = MPProvider();

  MPEngine({required this.flutterContext}) {
    _componentFactory = _MPComponentFactory(engine: this);
    _router = _MPRouter(engine: this);
    _textMeasurer = _TextMeasurer(engine: this);
    _drawableStore = _DrawableStore(engine: this);
    _jsContext = _JSContext();
    _mpjs = _MPJS(engine: this);
    _platformChannelIO = _MPPlatformChannelIO(engine: this);
  }

  void initWithJSCode(String jsCode) {
    _jsCode = jsCode;
  }

  void initWithDebuggerServerAddr(String debuggerServerAddr) {
    debugger = _MPDebugger(engine: this, serverAddr: debuggerServerAddr);
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
    if (_jsCode == null && debugger == null) return;
    updateWindowInfo();
    await _jsContext.createContext();
    await _setupJSContextEventChannel();
    await _setupDeferredLibraryLoader();
    await _MPJS.install(_jsContext);
    await _JSDeviceInfo.install(_jsContext, flutterContext);
    await _JSWXCompat.install(_jsContext);
    await _JSNetworkHttp.install(_jsContext, this);
    await _JSStorage.install(_jsContext, this);
    if (_jsCode != null) {
      await _jsContext.evaluateScript(_jsCode!);
    } else if (debugger != null) {
      debugger!.start();
    }
    for (final it in _messageQueue) {
      _jsContext.postMessage(it, '\$engine');
    }
    _messageQueue.clear();
    _started = true;
  }

  void stop() {
    debugger?.stop();
  }

  void clear() {
    _componentFactory.clear();
  }

  void updateWindowInfo() {
    _sendMessage({
      "type": "window_info",
      "message": {
        "window": {
          "width": MediaQuery.of(flutterContext).size.width,
          "height": MediaQuery.of(flutterContext).size.height,
          "padding": {
            "top": MediaQuery.of(flutterContext).padding.top,
            "bottom": MediaQuery.of(flutterContext).padding.bottom,
          }
        },
        "devicePixelRatio": MediaQuery.of(flutterContext).devicePixelRatio,
        "darkMode": MediaQuery.of(flutterContext).platformBrightness ==
            ui.Brightness.dark,
      },
    });
  }

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

  Future _setupDeferredLibraryLoader() async {
    _jsContext.addMessageListener((fileName, type) async {
      if (type == '\$engine.dartDeferredLibraryLoader') {
        if (_mpkReader != null) {
          final data = _mpkReader!.dataWithFilePath(fileName);
          if (data != null) {
            final code = utf8.decode(data);
            try {
              await _jsContext.evaluateScript(code);
              await _jsContext.evaluateScript('''
              globalThis.dartDeferredLoaderPromiser['$fileName'].resolver(null);
              ''');
            } catch (e) {
              await _jsContext.evaluateScript('''
              globalThis.dartDeferredLoaderPromiser['$fileName'].rejector(null);
              ''');
            }
          }
        }
      }
    });
    await _jsContext.evaluateScript('''
    globalThis.dartDeferredLoaderPromiser = {};
    globalThis.dartDeferredLibraryLoader = function(fileName, resolver, rejector) {
      globalThis.dartDeferredLoaderPromiser[fileName] = {resolver: resolver, rejector: rejector};
      globalThis.postMessage(fileName, '\$engine.dartDeferredLibraryLoader');
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
        if (decodedMessage['message']['event'] == 'doMeasure') {
          _textMeasurer._didReceivedDoMeasureData(decodedMessage['message']);
        } else if (decodedMessage['message']['event'] ==
            'doMeasureTextPainter') {
          _textMeasurer
              ._didReceivedDoMeasureTextPainer(decodedMessage['message']);
        }
        break;
      case 'action:web_dialogs':
        _WebDialogs.didReceivedWebDialogsMessage(
            decodedMessage['message'], this);
        break;
      case 'scroll_view':
        _didReceivedScrollView(decodedMessage['message']);
        break;
      case 'platform_view':
        MPPlatformView._didReceivedPlatformViewMessage(
            decodedMessage['message'], this);
        break;
      case 'mpjs':
        _mpjs._didReceivedMessage(decodedMessage['message']);
        break;
      case 'platform_channel':
        _platformChannelIO._didReceivedMessage(decodedMessage['message']);
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

  void _didReceivedScrollView(Map data) {
    if (data["event"] == "onRefreshEnd") {
      final target = _RefresherManager.findCompleter(data["target"]);
      if (target != null) {
        target.complete();
      }
    } else if (data["event"] == "jumpTo") {
      final target = _ScrollControllerManager.findController(data["target"]);
      if (target != null) {
        target.jumpTo(data["value"]);
      }
    }
  }

  void _addManageView(int viewId, MPDataReceiver view) {
    _managedViews[viewId] = view;
  }

  void _sendMessage(Map mapMessage) {
    String message = json.encode(mapMessage);
    if (debugger != null) {
      debugger!.sendMessage(message);
    } else {
      if (_jsContext._contextRef == null) {
        _messageQueue.add(message);
        return;
      }
      _jsContext.postMessage(message, '\$engine');
    }
  }
}
