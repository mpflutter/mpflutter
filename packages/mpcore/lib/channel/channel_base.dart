part of '../mpcore.dart';

bool requestingRoute = false;
String routeRequestId = '';

class MPNavigatorObserver extends NavigatorObserver {
  static final instance = MPNavigatorObserver();
  static bool doBacking = false;
  static bool initialPushed = false;

  String initialRoute = '/';
  Map initialParams = {};
  Map<int, Route> routeCache = {};
  Map<int, Size> routeViewport = {};

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route.settings.name?.startsWith('/mp_dialog/') == true) {
      return;
    }
    routeCache[route.hashCode] = route;
    if (requestingRoute) {
      final routeData = json.encode({
        'type': 'route',
        'message': {
          'event': 'responseRoute',
          'requestId': routeRequestId,
          'routeId': route.hashCode,
        },
      });
      MPChannel.postMesssage(routeData);
      requestingRoute = false;
    } else {
      if (!initialPushed && previousRoute == null) {
        initialPushed = true;
        return;
      }
      final routeData = json.encode({
        'type': 'route',
        'message': {
          'event': 'didPush',
          'routeId': route.hashCode,
          'name': route.settings.name ?? '/',
        },
      });
      MPChannel.postMesssage(routeData);
    }
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (doBacking) return;
    if (route.settings.name?.startsWith('/mp_dialog/') == true) {
      return;
    }
    final routeData = json.encode({
      'type': 'route',
      'message': {
        'event': 'didPop',
        'routeId': route.hashCode,
      },
    });
    MPChannel.postMesssage(routeData);
    super.didPop(route, previousRoute);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    routeCache.remove(route.hashCode);
    super.didRemove(route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute != null && oldRoute != null) {
      routeCache[newRoute.hashCode] = newRoute;
      if (requestingRoute) {
        final routeData = json.encode({
          'type': 'route',
          'message': {
            'event': 'responseRoute',
            'requestId': routeRequestId,
            'routeId': newRoute.hashCode,
          },
        });
        MPChannel.postMesssage(routeData);
        requestingRoute = false;
      } else {
        final routeData = json.encode({
          'type': 'route',
          'message': {
            'event': 'didReplace',
            'routeId': newRoute.hashCode,
            'name': newRoute.settings.name ?? '/',
          },
        });
        MPChannel.postMesssage(routeData);
      }
    }
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }
}

class MPChannelBase {
  static void handleClientMessage(msg) {
    try {
      final obj = json.decode(msg);
      if (obj['type'] == 'window_info') {
        MPChannelBase.onWindowInfo(obj['message']);
      } else if (obj['type'] == 'gesture_detector') {
        MPChannelBase.onGestureDetectorTrigger(obj['message']);
      } else if (obj['type'] == 'overlay') {
        MPChannelBase.onOverlayTrigger(obj['message']);
      } else if (obj['type'] == 'rich_text') {
        MPChannelBase.onRichTextTrigger(obj['message']);
      } else if (obj['type'] == 'scaffold') {
        MPChannelBase.onScaffoldTrigger(obj['message']);
      } else if (obj['type'] == 'decode_drawable') {
        MPChannelBase.onDecodeDrawable(obj['message']);
      } else if (obj['type'] == 'router') {
        MPChannelBase.onRouterTrigger(obj['message']);
      } else if (obj['type'] == 'editable_text') {
        MPChannelBase.onEditableTextTrigger(obj['message']);
      } else if (obj['type'] == 'action') {
        MPChannelBase.onActionTrigger(obj['message']);
      } else if (obj['type'] == 'mpjs') {
        mpjs.JsBridgeInvoker.instance.makeResponse(obj['message']);
      } else {
        MPChannelBase.onPluginMessage(obj);
      }
    } catch (e) {
      print(e);
    }
  }

  static void onWindowInfo(Map message) {
    try {
      final num devicePixelRatio = message['devicePixelRatio'];
      DeviceInfo.physicalSizeWidth =
          message['window']['width'].toDouble() * devicePixelRatio.toDouble();
      DeviceInfo.physicalSizeHeight =
          message['window']['height'].toDouble() * devicePixelRatio.toDouble();
      DeviceInfo.devicePixelRatio = devicePixelRatio.toDouble();
      DeviceInfo.windowPadding = ui.MockWindowPadding(
        left: 0.0,
        top: message['window']['padding']['top'] is num
            ? message['window']['padding']['top'].toDouble()
            : 0.0,
        right: 0.0,
        bottom: message['window']['padding']['bottom'] is num
            ? message['window']['padding']['bottom'].toDouble()
            : 0.0,
      );
      DeviceInfo.deviceSizeChangeCallback?.call();
    } catch (e) {
      print(e);
    }
  }

  static void onGestureDetectorTrigger(Map message) {
    try {
      final widget = MPCore.findTargetHashCode(message['target'])?.widget;
      if (!(widget is GestureDetector)) return;
      if (message['event'] == 'onTap') {
        widget.onTap?.call();
      }
    } catch (e) {
      print(e);
    }
  }

  static void onOverlayTrigger(Map message) {
    try {
      final widget = MPCore.findTargetHashCode(message['target'])?.widget;
      if (!(widget is MPOverlayScaffold)) return;
      if (message['event'] == 'onBackgroundTap') {
        widget.onBackgroundTap?.call();
      }
    } catch (e) {
      print(e);
    }
  }

  static void onRichTextTrigger(Map message) {
    try {
      if (message['event'] == 'onTap') {
        final widget = MPCore.findTargetHashCode(message['target'])?.widget;
        if (!(widget is RichText)) return;
        final span = MPCore.findTargetTextSpanHashCode(
          message['subTarget'],
          element: widget.text,
        );
        if (span?.recognizer is TapGestureRecognizer) {
          (span?.recognizer as TapGestureRecognizer).onTap?.call();
        }
      } else if (message['event'] == 'onMeasured') {
        _onMeasuredText(message['data']);
      }
    } catch (e) {
      print(e);
    }
  }

  static void onEditableTextTrigger(Map message) {
    try {
      final widget = MPCore.findTargetHashCode(message['target'])?.widget;
      if (!(widget is EditableText)) return;
      if (message['event'] == 'onSubmitted') {
        widget.onSubmitted?.call(message['data']);
      } else if (message['event'] == 'onChanged' && message['data'] is String) {
        widget.controller.text = message['data'];
        widget.controller.textDirty = false;
        widget.onChanged?.call(message['data']);
      }
    } catch (e) {
      print(e);
    }
  }

  static void onScaffoldTrigger(Map message) async {
    try {
      if (message['event'] == 'onRefresh') {
        final target = scaffoldStates.firstWhere(
          (scaffoldState) =>
              scaffoldState.context.hashCode == message['target'],
        );
        await target.widget.onRefresh?.call();
        MPChannel.postMesssage(json.encode({
          'type': 'scaffold',
          'message': {
            'event': 'onRefreshEnd',
            'target': message['target'],
          },
        }));
      } else if (message['event'] == 'onReachBottom') {
        final target = scaffoldStates.firstWhere(
          (scaffoldState) =>
              scaffoldState.context.hashCode == message['target'],
        );
        target.widget.onReachBottom?.call();
      }
    } catch (e) {
      print(e);
    }
  }

  static void onDecodeDrawable(Map message) {
    try {
      if (message['event'] == 'onDecode') {
        MPDrawable.receivedDecodedResult(message);
      } else if (message['event'] == 'onError') {
        MPDrawable.receivedDecodedError(message);
      }
    } catch (e) {
      print(e);
    }
  }

  static void onActionTrigger(Map message) {
    try {
      MPAction.onActionTrigger(message);
    } catch (e) {
      print(e);
    }
  }

  static void onRouterTrigger(Map message) {
    try {
      if (message['event'] == 'requestRoute') {
        requestingRoute = true;
        final name = message['name'] as String;
        routeRequestId = message['requestId'] as String;
        final params = (message['params'] as Map?) ?? {};
        if (message['viewport'] is Map) {
          params['\$viewportWidth'] = message['viewport']['width'];
          params['\$viewportHeight'] = message['viewport']['height'];
        }
        final root = message['root'] as bool;
        final navigator = MPNavigatorObserver.instance.navigator;
        if (navigator == null) return;
        if (root) {
          navigator.popUntil((route) {
            return false;
          });
          navigator.pushNamed(name, arguments: params);
        } else {
          navigator.pushNamed(name, arguments: params);
        }
      } else if (message['event'] == 'updateRoute') {
        final routeId = message['routeId'];
        final target = MPNavigatorObserver.instance.routeCache[routeId];
        if (target != null) {
          MPNavigatorObserver.instance.routeViewport[routeId] = Size(
            (message['viewport']['width'] as num).toDouble(),
            (message['viewport']['height'] as num).toDouble(),
          );
          routeScaffoldStateMap[routeId]?.refreshState();
        }
      } else if (message['event'] == 'disposeRoute') {
        final routeId = message['routeId'];
        final navigator = MPNavigatorObserver.instance.navigator;
        if (navigator == null) return;
        final target = MPNavigatorObserver.instance.routeCache[routeId];
        if (target != null && target.isActive) {
          navigator.removeRoute(target);
        }
      } else if (message['event'] == 'popToRoute') {
        final routeId = message['routeId'];
        final navigator = MPNavigatorObserver.instance.navigator;
        if (navigator == null) return;
        MPNavigatorObserver.doBacking = true;
        navigator.popUntil((dynamic route) {
          return route.hashCode == routeId;
        });
        MPNavigatorObserver.doBacking = false;
      }
    } catch (e) {
      print(e);
    }
  }

  static void onPluginMessage(Map message) {
    for (final plugin in MPCore._plugins) {
      plugin.onClientMessage(message);
    }
  }
}
