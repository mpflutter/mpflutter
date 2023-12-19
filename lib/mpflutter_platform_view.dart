import 'package:flutter/material.dart';
import './mpjs/mpjs.dart' as mpjs;

class _PlatformViewManager {
  static final shared = _PlatformViewManager();

  final mpjs.JSObject platformViewManager = mpjs.context["platformViewManager"];
  final bool runOnDevtools = mpjs.context["platformViewManager"]['devtools'];

  void updateView({
    required String viewClazz,
    required String pvid,
    required Rect frame,
    required EdgeInsets wrapper,
    required bool ignorePlatformTouch,
    required Map<String, dynamic> viewProps,
  }) {
    platformViewManager.callMethod("updateView", [
      {
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
        "ignorePlatformTouch": ignorePlatformTouch,
        "props": viewProps,
      }
    ]);
  }

  void disposeView(String viewClazz, String pvid) {
    platformViewManager.callMethod("disposeView", [
      {
        "viewClazz": viewClazz,
        "pvid": pvid,
      }
    ]);
  }
}

class MPFlutterPlatformViewController {
  String? pvid;
}

class MPFlutterPlatformView extends StatefulWidget {
  final MPFlutterPlatformViewController? controller;
  final String viewClazz;
  final bool ignorePlatformTouch;
  final Map<String, dynamic> viewProps;

  const MPFlutterPlatformView({
    super.key,
    this.controller,
    required this.viewClazz,
    this.ignorePlatformTouch = false,
    this.viewProps = const {},
  });

  @override
  State<MPFlutterPlatformView> createState() => _MPFlutterPlatformViewState();
}

class _MPFlutterPlatformViewState extends State<MPFlutterPlatformView> {
  final renderBoxKey = GlobalKey();

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
    WidgetsBinding.instance.addPostFrameCallback(_updateViewFrame);
  }

  @override
  void didUpdateWidget(covariant MPFlutterPlatformView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateViewFrame(0);
  }

  void _updateViewFrame(dynamic time) {
    if (!mounted) return;
    final RenderBox? renderBox =
        renderBoxKey.currentContext?.findRenderObject() as RenderBox?;
    final offset = renderBox?.localToGlobal(Offset.zero);
    final size = renderBox?.size;
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
        color: Colors.white,
        child: Center(
          child: Text(
            '开发者工具无法预览 PlatformView\n请在真机预览',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return Container(
      key: renderBoxKey,
      color: Colors.white,
    );
  }
}
