import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import './mpjs/mpjs.dart' as mpjs;

typedef MPFlutterPlatformViewCallback = void Function(
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
}

class MPFlutterPlatformView extends StatefulWidget {
  final MPFlutterPlatformViewController? controller;
  final bool transparent;
  final String viewClazz;
  final bool ignorePlatformTouch;
  final Map<String, dynamic> viewProps;
  final MPFlutterPlatformViewCallback? eventCallback;

  const MPFlutterPlatformView({
    super.key,
    this.controller,
    required this.viewClazz,
    this.transparent = false,
    this.ignorePlatformTouch = false,
    this.viewProps = const {},
    this.eventCallback,
  });

  @override
  State<MPFlutterPlatformView> createState() => _MPFlutterPlatformViewState();
}

class _MPFlutterPlatformViewState extends State<MPFlutterPlatformView> {
  final renderBoxKey = GlobalKey();
  Route? currentRoute;

  @override
  void dispose() {
    _PlatformViewManager.shared.disposeView(
      widget.viewClazz,
      renderBoxKey.hashCode.toString(),
    );
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
    }
    WidgetsBinding.instance.addPostFrameCallback(_updateViewFrame);
  }

  @override
  void didUpdateWidget(covariant MPFlutterPlatformView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateViewFrame(0);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    currentRoute = ModalRoute.of(context);
  }

  void _updateViewFrame(dynamic time) {
    if (!mounted) return;
    final RenderBox? renderBox =
        renderBoxKey.currentContext?.findRenderObject() as RenderBox?;
    final offset = renderBox?.localToGlobal(Offset.zero);
    final size = renderBox?.size;
    final opcaityObject = renderBoxKey.currentContext
        ?.findAncestorRenderObjectOfType<RenderOpacity>();
    if (offset != null && size != null) {
      final frameOnWindow = Rect.fromLTWH(
        offset.dx,
        offset.dy,
        size.width,
        size.height,
      );
      _PlatformViewManager.shared.updateView(
        viewClazz: widget.viewClazz,
        pvid: renderBoxKey.hashCode.toString(),
        frame: frameOnWindow,
        wrapper: EdgeInsets.only(
          top: (Scaffold.of(context).appBarMaxHeight ?? 0),
        ),
        opacity: (currentRoute == null || currentRoute!.isCurrent == false)
            ? 0.0
            : (opcaityObject?.opacity ?? 1.0),
        ignorePlatformTouch: widget.ignorePlatformTouch,
        viewProps: widget.viewProps,
      );
    }
    WidgetsBinding.instance.addPostFrameCallback(_updateViewFrame);
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
      child: Container(
        key: renderBoxKey,
        color: Colors.transparent,
      ),
    );
  }
}
