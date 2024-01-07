// Copyright 2023 The MPFlutter Authors. All rights reserved.
// Use of this source code is governed by a Apache License Version 2.0 that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';

import 'package:mpflutter_core/mpflutter_core.dart';

import './mpjs/mpjs.dart';

class MPFlutterWechatAppDelegate {
  bool _launched = false;
  final void Function(Map query)? onLaunch;
  final void Function(Map query)? onEnter;
  final void Function()? onShow;
  final void Function()? onHide;
  final Map Function(JSObject)? onShareAppMessage;

  MPFlutterWechatAppDelegate({
    this.onLaunch,
    this.onEnter,
    this.onShow,
    this.onHide,
    this.onShareAppMessage,
  }) {
    if (kIsMPFlutter) {
      try {
        _addCallbackListenner();
        _readyToLaunch();
      } catch (e) {
        print(e);
      }
    }
  }

  void _addCallbackListenner() {
    final mpcbObject = JSObject("Object");
    mpcbObject["onShow"] = onShow;
    mpcbObject["onHide"] = onHide;
    mpcbObject["onShareAppMessage"] = onShareAppMessage;
    mpcbObject["onEnter"] = (JSObject query) {
      onEnter?.call(query.asMap());
    };
    context["wx"]["mpcb"] = mpcbObject;
  }

  void _readyToLaunch() {
    if (!_launched) {
      _launched = true;
      final launchOptions =
          (context["wx"] as JSObject).callMethod("getLaunchOptionsSync");
      onLaunch?.call((launchOptions["query"] as JSObject).asMap());
    }
  }
}

class MPFlutterWechatAppShareInfo {
  final String title;
  final String? imageUrl;
  final Map query;
  MPFlutterWechatAppShareInfo({
    required this.title,
    this.imageUrl,
    required this.query,
  });
}

class MPFlutterWechatAppShareManager {
  static Map<int, MPFlutterWechatAppShareInfo> _routeShareInfos = {};

  static Map onShareAppMessage(JSObject detail) {
    final currentRoute = MPNavigatorObserver.currentRoute;
    if (currentRoute != null &&
        _routeShareInfos[currentRoute.hashCode] != null) {
      final appShareInfo = _routeShareInfos[currentRoute.hashCode]!;
      return {
        "title": appShareInfo.title,
        "imageUrl": appShareInfo.imageUrl,
        "path": "pages/index/index?${(() {
          final map = appShareInfo.query;
          String query = "";
          map.forEach((key, value) {
            query += "$key=${Uri.encodeFull(value)}";
          });
          return query;
        })()}",
      };
    } else {
      return {};
    }
  }

  static void setAppShareInfo({
    required BuildContext context,
    required String title,
    String? imageUrl,
    required Map query,
  }) {
    final route = ModalRoute.of(context);
    if (route != null) {
      _routeShareInfos[route.hashCode] = MPFlutterWechatAppShareInfo(
        title: title,
        imageUrl: imageUrl,
        query: query,
      );
    }
  }
}
