// Copyright 2023 The MPFlutter Authors. All rights reserved.
// Use of this source code is governed by a Apache License Version 2.0 that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:visibility_detector/visibility_detector.dart';
import './mpjs/mpjs.dart' as mpjs;
import 'mpflutter_core.dart';

typedef MPFlutterPlatformViewCallback = dynamic Function(
    String event, mpjs.JSObject detail);

String getPVID(GlobalKey renderBoxKey) {
  return "pvid_" + renderBoxKey.hashCode.toString();
}

class _PlatformViewManager {
  static final shared = _PlatformViewManager();

  final mpjs.JSObject platformViewManager = mpjs.context["platformViewManager"];
  final bool runOnDevtools = mpjs.context["platformViewManager"]['devtools'];
  final Map<String, Map> pvidOptionCache = {};
  var _holderId = 0;

  void setWindowLevel(int windowLevel, int holderId) {
    if (windowLevel > 0) {
      _holderId = holderId;
    }
    if (_holderId != holderId) {
      return;
    }
    platformViewManager.callMethod("setWindowLevel", [windowLevel]);
  }

  void addCBListenner(String pvid, MPFlutterPlatformViewCallback callback) {
    platformViewManager.callMethod("addCBListenner", [
      pvid,
      callback,
    ]);
  }

  void batchBegin() {
    platformViewManager.callMethod("batchSetDataBegin", []);
  }

  void batchCommit() {
    platformViewManager.callMethod("batchSetDataCommit", []);
  }

  void updateView({
    required String viewClazz,
    required String pvid,
    required Rect frame,
    required EdgeInsets wrapper,
    required double opacity,
    required bool ignorePlatformTouch,
    required Map<String, dynamic> viewProps,
    bool forceUpdate = false,
  }) {
    final newOption = {
      "viewClazz": viewClazz,
      "pvid": pvid,
      "frame": {
        "x": frame.left,
        "y": frame.top,
        "width": frame.width,
        "height": frame.height,
      },
      "wrapper": {
        "top": wrapper.top,
        "left": wrapper.left,
        "bottom": wrapper.bottom,
        "right": wrapper.right,
      },
      "opacity": opacity,
      "ignorePlatformTouch": ignorePlatformTouch,
      "props": viewProps,
    };
    if (pvidOptionCache[pvid] != null &&
        _deepCompare(newOption, pvidOptionCache[pvid]!)) {
      if (!forceUpdate) {
        return;
      }
    }
    pvidOptionCache[pvid] = newOption;
    platformViewManager.callMethod("updateView", [newOption]);
  }

  void disposeView(String viewClazz, String pvid) {
    platformViewManager.callMethod("disposeView", [
      {
        "viewClazz": viewClazz,
        "pvid": pvid,
      }
    ]);
  }

  void updateOverlay({
    required String pvid,
    required Rect frame,
    BorderRadius? borderRadius,
    String? visibility,
  }) {
    final newOption = {
      "pvid": pvid,
      "x": frame.left,
      "y": frame.top,
      "width": frame.width,
      "height": frame.height,
      "borderRadius": borderRadius?.topLeft.x ?? 0,
      "visibility": visibility ?? "unset",
    };
    if (pvidOptionCache[pvid] != null &&
        _deepCompare(newOption, pvidOptionCache[pvid]!)) {
      refreshOverlay(pvid);
      return;
    }
    pvidOptionCache[pvid] = newOption;
    platformViewManager.callMethod("updateOverlay", [newOption]);
  }

  void disposeOverlay(String pvid) {
    platformViewManager.callMethod("disposeOverlay", [
      {
        "pvid": pvid,
      }
    ]);
  }

  void refreshOverlay(String pvid) {
    platformViewManager.callMethod("refreshOverlay", [
      {
        "pvid": pvid,
      }
    ]);
  }

  bool _deepCompare(Map<dynamic, dynamic> map1, Map<dynamic, dynamic> map2) {
    if (map1.length != map2.length) {
      return false;
    }

    for (var key in map1.keys) {
      if (!map2.containsKey(key)) {
        return false;
      }

      var value1 = map1[key];
      var value2 = map2[key];

      if (value1 is Map<dynamic, dynamic> && value2 is Map<dynamic, dynamic>) {
        if (!_deepCompare(value1, value2)) {
          return false;
        }
      } else if (value1 != value2) {
        return false;
      }
    }

    return true;
  }
}

class MPFlutterPlatformViewController {
  String? pvid;

  dispose() {
    pvid = null;
  }
}

class MPFlutterPlatformViewport extends StatelessWidget {
  final Widget child;
  final double? topHeight;
  final double? bottomHeight;

  const MPFlutterPlatformViewport({
    super.key,
    required this.child,
    this.topHeight,
    this.bottomHeight,
  });

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

class MPFlutterPlatformView extends StatefulWidget {
  static final _frameUpdater = ChangeNotifier();
  static var _frameUpdaterInstalled = false;

  static void installFrameUpdater() {
    if (_frameUpdaterInstalled) return;
    _frameUpdaterInstalled = true;
    WidgetsBinding.instance.addPersistentFrameCallback((_) {
      _PlatformViewManager.shared.batchBegin();
      _frameUpdater.notifyListeners();
      _PlatformViewManager.shared.batchCommit();
    });
  }

  final MPFlutterPlatformViewController? controller;
  final bool transparent;
  final String viewClazz;
  final bool ignorePlatformTouch;
  final Map<String, dynamic> viewProps;
  final MPFlutterPlatformViewCallback? eventCallback;
  final bool delayUpdate;
  final Widget? placeholder;

  const MPFlutterPlatformView({
    super.key,
    this.controller,
    required this.viewClazz,
    this.transparent = false,
    this.ignorePlatformTouch = false,
    this.viewProps = const {},
    this.eventCallback,
    this.delayUpdate = false,
    this.placeholder,
  });

  @override
  State<MPFlutterPlatformView> createState() {
    if (!kIsMPFlutter) {
      return _MPFlutterPlatformViewState_NOOP();
    }
    if (kIsMPFlutterDevmode) {
      return _MPFlutterPlatformViewState_IO();
    }
    return _MPFlutterPlatformViewState();
  }
}

class _MPFlutterPlatformViewState_NOOP extends State<MPFlutterPlatformView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: widget.transparent
          ? null
          : Center(
              child: Text(
                '非 MPFlutter 环境，无法使用 PlatformView。',
                textAlign: TextAlign.center,
              ),
            ),
    );
  }
}

class _MPFlutterPlatformViewState_IO extends State<MPFlutterPlatformView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: widget.transparent
          ? null
          : Center(
              child: Text(
                'HotReload 场景无法使用 PlatformView。\n请在真机预览',
                textAlign: TextAlign.center,
              ),
            ),
    );
  }
}

class _MPFlutterPlatformViewState extends State<MPFlutterPlatformView> {
  final renderBoxKey = GlobalKey();
  Route? currentRoute;
  double topHeight = 0;
  double bottomHeight = 0;
  bool visible = true;
  bool? lastVisible;
  _Debouncer _debouncer = _Debouncer();
  _Throttler _throttler = _Throttler(delay: Duration(milliseconds: 300));

  @override
  void dispose() {
    _PlatformViewManager.shared.disposeView(
      widget.viewClazz,
      getPVID(renderBoxKey),
    );
    widget.controller?.dispose();
    MPFlutterPlatformView._frameUpdater
        .removeListener(_onUpdateViewFrameSingal);
    MPNavigatorObserver.shared?.removeListener(_onUpdateViewFrameRouteChanged);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    widget.controller?.pvid = getPVID(renderBoxKey);
    if (widget.eventCallback != null) {
      _PlatformViewManager.shared.addCBListenner(
        getPVID(renderBoxKey),
        widget.eventCallback!,
      );
    } else {
      _PlatformViewManager.shared.addCBListenner(
        getPVID(renderBoxKey),
        (String event, mpjs.JSObject detail) {},
      );
    }
    MPFlutterPlatformView.installFrameUpdater();
    MPFlutterPlatformView._frameUpdater.addListener(_onUpdateViewFrameSingal);
  }

  @override
  void didUpdateWidget(covariant MPFlutterPlatformView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateViewFrame();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    currentRoute = ModalRoute.of(context);
    topHeight = (() {
      final viewport =
          context.findAncestorWidgetOfExactType<MPFlutterPlatformViewport>();
      try {
        return viewport?.topHeight ?? Scaffold.of(context).appBarMaxHeight ?? 0;
      } catch (e) {
        return 0.0;
      }
    })();
    bottomHeight = (() {
      final viewport =
          context.findAncestorWidgetOfExactType<MPFlutterPlatformViewport>();
      try {
        return viewport?.bottomHeight ?? 0;
      } catch (e) {
        return 0.0;
      }
    })();
    _updateViewFrame();
    MPNavigatorObserver.shared?.addListener(_onUpdateViewFrameRouteChanged);
  }

  void _onUpdateViewFrameRouteChanged() {
    Future.delayed(Duration(milliseconds: 300)).then((value) {
      if (currentRoute?.isCurrent == true) {
        visible = lastVisible ?? true;
      } else {
        lastVisible = visible;
      }
      _updateViewFrame(forceUpdate: true);
    });
  }

  void _onUpdateViewFrameSingal() {
    if (widget.delayUpdate) {
      _debouncer.run(_updateViewFrame, Duration(milliseconds: 300));
      _throttler.run(_updateViewFrame);
    } else {
      _updateViewFrame();
    }
  }

  void _updateViewFrame({bool forceUpdate = false}) {
    if (!mounted) {
      return;
    }
    final RenderBox? renderBox =
        renderBoxKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    final opcaityObject = renderBoxKey.currentContext
        ?.findAncestorRenderObjectOfType<RenderOpacity>();
    final frameOnWindow = Rect.fromLTWH(
      offset.dx.isNaN ? -1000 : offset.dx,
      offset.dy.isNaN ? -1000 : offset.dy,
      size.width,
      size.height,
    );
    _PlatformViewManager.shared.updateView(
      viewClazz: widget.viewClazz,
      pvid: getPVID(renderBoxKey),
      frame: frameOnWindow,
      wrapper: EdgeInsets.only(top: topHeight, bottom: bottomHeight),
      opacity:
          (currentRoute == null || currentRoute!.isCurrent == false || !visible)
              ? 0.0
              : (opcaityObject?.opacity ?? 1.0),
      ignorePlatformTouch: widget.ignorePlatformTouch,
      viewProps: widget.viewProps,
      forceUpdate: forceUpdate,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_PlatformViewManager.shared.runOnDevtools) {
      return Container(
        key: renderBoxKey,
        color: Colors.transparent,
        child: widget.transparent
            ? null
            : Center(
                child: Text(
                  '开发者工具无法预览 PlatformView\n请在真机预览',
                  textAlign: TextAlign.center,
                ),
              ),
      );
    }
    return GestureDetector(
      onPanStart: (_) {},
      onPanUpdate: (_) {},
      onPanEnd: (_) {},
      onPanCancel: () {},
      child: VisibilityDetector(
        key: renderBoxKey,
        onVisibilityChanged: (value) {
          final nextVisible = value.visibleBounds.size.width > 0 &&
              value.visibleBounds.size.height > 0;
          if (nextVisible != visible) {
            setState(() {
              visible = nextVisible;
            });
            _updateViewFrame();
          }
        },
        child: Container(
          color: Colors.transparent,
          child: currentRoute?.isCurrent != true ? widget.placeholder : null,
        ),
      ),
    );
  }
}

class MPFlutterPlatformOverlay extends StatefulWidget {
  final Widget? child;

  const MPFlutterPlatformOverlay({
    super.key,
    this.child,
  });

  @override
  State<MPFlutterPlatformOverlay> createState() {
    if (!kIsMPFlutter) {
      return _MPFlutterPlatformOverlayState_NOOP();
    }
    if (kIsMPFlutterDevmode) {
      return _MPFlutterPlatformOverlayState_NOOP();
    }
    return _MPFlutterPlatformOverlayState();
  }
}

class _MPFlutterPlatformOverlayState_NOOP
    extends State<MPFlutterPlatformOverlay> {
  @override
  Widget build(BuildContext context) {
    return widget.child ?? SizedBox();
  }
}

class _MPFlutterPlatformOverlayState extends State<MPFlutterPlatformOverlay> {
  final renderBoxKey = GlobalKey();
  Route? currentRoute;
  bool visible = true;
  bool? lastVisible;

  @override
  void dispose() {
    _PlatformViewManager.shared.disposeOverlay(
      getPVID(renderBoxKey),
    );
    MPFlutterPlatformView._frameUpdater
        .removeListener(_onUpdateViewFrameSingal);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    MPFlutterPlatformView.installFrameUpdater();
    MPFlutterPlatformView._frameUpdater.addListener(_onUpdateViewFrameSingal);
  }

  @override
  void didUpdateWidget(covariant MPFlutterPlatformOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateViewFrame();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    currentRoute = ModalRoute.of(context);
    _updateViewFrame();
    MPNavigatorObserver.shared?.addListener(_onUpdateViewFrameRouteChanged);
  }

  void _onUpdateViewFrameRouteChanged() {
    Future.delayed(Duration(milliseconds: 300)).then((value) {
      if (currentRoute?.isCurrent == true) {
        visible = lastVisible ?? true;
      } else {
        lastVisible = visible;
      }
      _updateViewFrame();
    });
  }

  void _onUpdateViewFrameSingal() {
    _updateViewFrame();
  }

  void _updateViewFrame() {
    if (!mounted) {
      return;
    }
    final RenderBox? renderBox =
        renderBoxKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    final frameOnWindow = Rect.fromLTWH(
      offset.dx.isNaN ? -1000 : offset.dx,
      offset.dy.isNaN ? -1000 : offset.dy,
      size.width,
      size.height,
    );
    _PlatformViewManager.shared.updateOverlay(
      pvid: getPVID(renderBoxKey),
      frame: frameOnWindow,
      visibility:
          (currentRoute == null || currentRoute!.isCurrent == false || !visible)
              ? "hidden"
              : "unset",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: renderBoxKey,
      child: widget.child,
    );
  }
}

class MPFlutterPlatformOverlaySupport extends StatefulWidget {
  final Widget child;

  const MPFlutterPlatformOverlaySupport({super.key, required this.child});

  @override
  State<MPFlutterPlatformOverlaySupport> createState() {
    if (!kIsMPFlutter || kIsMPFlutterDevmode) {
      return _MPFlutterPlatformOverlaySupportState_NOOP();
    }
    return _MPFlutterPlatformOverlaySupportState();
  }
}

class _MPFlutterPlatformOverlaySupportState_NOOP
    extends State<MPFlutterPlatformOverlaySupport> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class _MPFlutterPlatformOverlaySupportState
    extends State<MPFlutterPlatformOverlaySupport> {
  Route? currentRoute;

  @override
  void dispose() {
    MPNavigatorObserver.shared?.removeListener(_updateWindowLevel);
    _updateWindowLevel();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant MPFlutterPlatformOverlaySupport oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateWindowLevel();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    currentRoute = ModalRoute.of(context);
    MPNavigatorObserver.shared?.addListener(_updateWindowLevel);
    _updateWindowLevel();
  }

  void _updateWindowLevel() {
    if (mounted && currentRoute != null && currentRoute!.isCurrent == true) {
      _PlatformViewManager.shared.setWindowLevel(20000, currentRoute.hashCode);
    } else {
      _PlatformViewManager.shared.setWindowLevel(0, currentRoute.hashCode);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class _Throttler {
  final Duration delay;
  bool _isRunning = false;

  _Throttler({required this.delay});

  void run(VoidCallback action) {
    if (!_isRunning) {
      _isRunning = true;
      action();
      Timer(delay, () {
        _isRunning = false;
      });
    }
  }
}

class _Debouncer {
  Timer? _timer;

  void run(Function function, Duration duration) {
    if (_timer != null && _timer!.isActive) {
      _timer!.cancel();
    }

    _timer = Timer(duration, () {
      function();
    });
  }
}
