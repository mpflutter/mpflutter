import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:mpflutter_core/mpjs/mpjs.dart' as mpjs;

import '../dev_app/runApp.dart'
    if (dart.library.js) '../wechat_app/runApp.dart';

class DouyinNavigator {
  static DouyinNavigator of(BuildContext context) {
    final navigator = Navigator.of(context);
    DouyinNativeNavigatorHandler.shared ??=
        DouyinNativeNavigatorHandler(navigator);
    return DouyinNavigator(navigator);
  }

  final NavigatorState navigator;

  DouyinNavigator(this.navigator);

  void pushNamed(
    String routeName, {
    Object? arguments,
  }) {
    final a = mpjs.JSObject("Object");
    a["url"] = '/pages/index/next';
    (mpjs.context["tt"] as mpjs.JSObject).callMethod(
      'navigateTo',
      [a],
    );
    (mpjs.context["tt"] as mpjs.JSObject)["flutterReadyToPushRoute"] = () {
      navigator.pushNamed(routeName, arguments: arguments);
    };
  }

  void pop() {
    if (navigator.canPop()) {
      (mpjs.context["tt"] as mpjs.JSObject).callMethod(
        'navigateBack',
        [],
      );
      navigator.pop();
    }
  }
}

class DouyinNativeNavigatorHandler {
  static DouyinNativeNavigatorHandler? shared;

  final NavigatorState navigator;

  DouyinNativeNavigatorHandler(this.navigator) {
    installHandler();
  }

  void installHandler() {
    mpjs.context["tt"]["flutterNavigatorBackHandler"] = (int toPage) {
      final currentPage = MPNavigatorObserverPrivate.currentRouteCount;
      final delta = currentPage - toPage;
      if (delta <= 0) return;
      int poped = 0;
      navigator.popUntil((route) {
        if (poped == delta) {
          return true;
        }
        poped++;
        return false;
      });
    };
  }
}

class DouyinAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  DouyinAppBar({this.title});

  @override
  Widget build(BuildContext context) {
    return SizedBox();
  }

  @override
  Size get preferredSize => Size.fromHeight(0);
}
