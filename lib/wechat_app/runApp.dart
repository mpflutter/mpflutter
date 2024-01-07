import 'dart:async';

import 'package:flutter/widgets.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;

import 'package:mpflutter_core/mpflutter_core.dart';

class MPApp extends StatefulWidget {
  final Widget child;

  const MPApp({super.key, required this.child});

  @override
  State<MPApp> createState() => _MPAppState();
}

class _MPAppState extends State<MPApp> {
  double safeAreaInsetTop = 0.0;
  double safeAreaInsetBottom = 0.0;
  double keyboardHeight = 0.0;

  @override
  void initState() {
    super.initState();
    if (!kIsMPFlutter) {
      return;
    }
    safeAreaInsetTop = js.context["safeAreaInsetTop"] is num
        ? (js.context["safeAreaInsetTop"] as num).toDouble()
        : 0.0;
    safeAreaInsetBottom = js.context["safeAreaInsetBottom"] is num
        ? (js.context["safeAreaInsetBottom"] as num).toDouble()
        : 50.0;
    js.context["keyboardHeightChanged"] = (num value) {
      if (keyboardHeight == value) {
        return;
      }
      keyboardHeight = value.toDouble();
      Timer(Duration(milliseconds: 100), () {
        if (keyboardHeight == value) {
          setState(() {});
        }
      });
    };
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsMPFlutter) {
      return widget.child;
    }
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        padding: EdgeInsets.only(
          top: safeAreaInsetTop,
          bottom: safeAreaInsetBottom,
        ),
        viewInsets: EdgeInsets.only(bottom: keyboardHeight),
      ),
      child: widget.child,
    );
  }
}

class MPNavigatorObserverPrivate extends NavigatorObserver {
  static Route? currentRoute;

  MPNavigatorObserverPrivate() {
    if (!kIsMPFlutter) {
      return;
    }
    js.context["androidBackPressed"] = () {
      final ctx = navigator?.context;
      if (ctx != null && Navigator.canPop(ctx)) {
        Navigator.pop(ctx);
      }
    };
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    if (!kIsMPFlutter) {
      return;
    }
    currentRoute = route;
    if (!route.isFirst) {
      (js.context["FlutterHostView"]["shared"] as js.JsObject)
          .callMethod("requireCatchBack", [true]);
    } else {
      (js.context["FlutterHostView"]["shared"] as js.JsObject)
          .callMethod("requireCatchBack", [false]);
    }
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    if (!kIsMPFlutter) {
      return;
    }
    currentRoute = previousRoute;
    if (previousRoute?.isFirst == true) {
      (js.context["FlutterHostView"]["shared"] as js.JsObject)
          .callMethod("requireCatchBack", [false]);
    }
  }
}
