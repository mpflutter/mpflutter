// Copyright 2023 The MPFlutter Authors. All rights reserved.
// Use of this source code is governed by a Apache License Version 2.0 that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:visibility_detector/visibility_detector.dart';
import './mpjs/mpjs.dart' as mpjs;

typedef MPFlutterPlatformViewCallback = dynamic Function(
    String event, mpjs.JSObject detail);

class _PlatformViewManager {
  static final shared = _PlatformViewManager();

  final mpjs.JSObject platformViewManager = mpjs.context["platformViewManager"];
  final bool runOnDevtools = mpjs.context["platformViewManager"]['devtools'];
  final Map<String, Map> pvidOptionCache = {};

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
      return;
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
    this.topHeight = null,
    this.bottomHeight = null,
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

  const MPFlutterPlatformView({
    super.key,
    this.controller,
    required this.viewClazz,
    this.transparent = false,
    this.ignorePlatformTouch = false,
    this.viewProps = const {},
    this.eventCallback,
    this.delayUpdate = false,
  });

  @override
  State<MPFlutterPlatformView> createState() => _MPFlutterPlatformViewState();
}

class _MPFlutterPlatformViewState extends State<MPFlutterPlatformView> {
  final renderBoxKey = GlobalKey();
  Route? currentRoute;
  double topHeight = 0;
  double bottomHeight = 0;
  bool visible = true;
  _Debouncer _debouncer = _Debouncer();
  _Throttler _throttler = _Throttler(delay: Duration(milliseconds: 300));

  @override
  void dispose() {
    _PlatformViewManager.shared.disposeView(
      widget.viewClazz,
      renderBoxKey.hashCode.toString(),
    );
    widget.controller?.dispose();
    MPFlutterPlatformView._frameUpdater
        .removeListener(_onUpdateViewFrameSingal);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    widget.controller?.pvid = renderBoxKey.hashCode.toString();
    if (widget.eventCallback != null) {
      _PlatformViewManager.shared.addCBListenner(
        renderBoxKey.hashCode.toString(),
        widget.eventCallback!,
      );
    } else {
      _PlatformViewManager.shared.addCBListenner(
        renderBoxKey.hashCode.toString(),
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
  }

  void _onUpdateViewFrameSingal() {
    if (widget.delayUpdate) {
      _debouncer.run(_updateViewFrame, Duration(milliseconds: 300));
      _throttler.run(_updateViewFrame);
    } else {
      _updateViewFrame();
    }
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
      pvid: renderBoxKey.hashCode.toString(),
      frame: frameOnWindow,
      wrapper: EdgeInsets.only(top: topHeight, bottom: bottomHeight),
      opacity:
          (currentRoute == null || currentRoute!.isCurrent == false || !visible)
              ? 0.0
              : (opcaityObject?.opacity ?? 1.0),
      ignorePlatformTouch: widget.ignorePlatformTouch,
      viewProps: widget.viewProps,
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
            visible = nextVisible;
            _updateViewFrame();
          }
        },
        child: Container(
          color: Colors.transparent,
        ),
      ),
    );
  }
}

class _Throttler {
  final Duration delay;
  Timer? _timer;
  bool _isRunning = false;

  _Throttler({required this.delay});

  void run(VoidCallback action) {
    if (!_isRunning) {
      _isRunning = true;
      action();
      _timer = Timer(delay, () {
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
