// Copyright 2023 The MPFlutter Authors. All rights reserved.
// Use of this source code is governed by a Apache License Version 2.0 that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';

import 'package:mpflutter_core/mpflutter_core.dart';

import './mpjs/mpjs.dart';

class MPFlutterWechatAppDelegate {
  bool _launched = false;
  final void Function(Map query, JSObject launchOptions)? onLaunch;
  final void Function(Map query, JSObject launchOptions)? onEnter;
  final void Function()? onShow;
  final void Function()? onHide;
  final Map Function()? onSaveExitState;
  final Map Function(JSObject)? onShareAppMessage;
  final void Function(JSObject, Function(Map))? onShareAppMessageAsync;
  final Map Function(JSObject)? onShareTimeline;
  final void Function(JSObject, Function(Map))? onShareTimelineAsync;
  final Map Function(JSObject)? onAddToFavorites;
  final void Function(JSObject, Function(Map))? onAddToFavoritesAsync;

  MPFlutterWechatAppDelegate({
    this.onLaunch,
    this.onEnter,
    this.onShow,
    this.onHide,
    this.onSaveExitState,
    this.onShareAppMessage,
    this.onShareAppMessageAsync,
    this.onShareTimeline,
    this.onShareTimelineAsync,
    this.onAddToFavorites,
    this.onAddToFavoritesAsync,
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

  static JSObject exitState() {
    return context["wx"]["mpcbExitState"];
  }

  void _addCallbackListenner() {
    final mpcbObject = JSObject("Object");
    mpcbObject["onShow"] = onShow;
    mpcbObject["onHide"] = onHide;
    mpcbObject["onSaveExitState"] = onSaveExitState;
    mpcbObject["onShareAppMessage"] = onShareAppMessage;
    if (onShareAppMessageAsync != null) {
      mpcbObject["onShareAppMessageAsync"] =
          (JSObject detail, JSFunction callback) {
        onShareAppMessageAsync?.call(detail, (result) {
          callback.call([result]);
        });
      };
    }
    mpcbObject["onShareTimeline"] = onShareTimeline;
    if (onShareTimelineAsync != null) {
      mpcbObject["onShareTimelineAsync"] =
          (JSObject detail, JSFunction callback) {
        onShareTimelineAsync?.call(detail, (result) {
          callback.call([result]);
        });
      };
    }
    mpcbObject["onAddToFavorites"] = onAddToFavorites;
    if (onAddToFavoritesAsync != null) {
      mpcbObject["onAddToFavoritesAsync"] =
          (JSObject detail, JSFunction callback) {
        onAddToFavoritesAsync?.call(detail, (result) {
          callback.call([result]);
        });
      };
    }
    mpcbObject["onEnter"] = (JSObject query) {
      final enterOptions = (context["wx"] as JSObject).callMethod(
        "getEnterOptionsSync",
      );
      onEnter?.call(query.asMap(), enterOptions);
    };
    context["wx"]["mpcb"] = mpcbObject;
  }

  void _readyToLaunch() {
    if (!_launched) {
      _launched = true;
      final launchOptions =
          (context["wx"] as JSObject).callMethod("getLaunchOptionsSync");
      onLaunch?.call(
        (launchOptions["query"] as JSObject).asMap(),
        launchOptions,
      );
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
            query += "$key=${Uri.encodeFull(value)}&";
          });
          return query;
        })()}",
      };
    } else {
      return {};
    }
  }

  static Map onShareTimeline(JSObject detail) {
    final currentRoute = MPNavigatorObserver.currentRoute;
    if (currentRoute != null &&
        _routeShareInfos[currentRoute.hashCode] != null) {
      final appShareInfo = _routeShareInfos[currentRoute.hashCode]!;
      return {
        "title": appShareInfo.title,
        "query": "${(() {
          final map = appShareInfo.query;
          String query = "";
          map.forEach((key, value) {
            query += "$key=${Uri.encodeFull(value)}&";
          });
          return query;
        })()}",
      };
    } else {
      return {};
    }
  }

  static Map onAddToFavorites(JSObject detail) {
    final currentRoute = MPNavigatorObserver.currentRoute;
    if (currentRoute != null &&
        _routeShareInfos[currentRoute.hashCode] != null) {
      final appShareInfo = _routeShareInfos[currentRoute.hashCode]!;
      return {
        "title": appShareInfo.title,
        "imageUrl": appShareInfo.imageUrl,
        "query": "${(() {
          final map = appShareInfo.query;
          String query = "";
          map.forEach((key, value) {
            query += "$key=${Uri.encodeFull(value)}&";
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
