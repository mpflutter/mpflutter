import 'package:flutter/widgets.dart';

import 'package:mpflutter_core/mpflutter_core.dart';

import './mpjs/mpjs.dart';

class MPFlutterWechatLaunchOption {
  final String path;
  final JSObject query;
  MPFlutterWechatLaunchOption({required this.path, required this.query});
}

class MPFlutterWechatEnterOption {
  final String path;
  final JSObject query;
  MPFlutterWechatEnterOption({required this.path, required this.query});
}

class MPFlutterWechatAppDelegate {
  final void Function(MPFlutterWechatLaunchOption)? onLaunch;
  final void Function()? onShow;
  final void Function()? onHide;
  final Map Function(JSObject)? onShareAppMessage;

  static MPFlutterWechatLaunchOption? getLaunchOption() {
    if (kIsMPFlutter) {
      final result = (context["wx"] as JSObject).callMethod(
        "getLaunchOptionsSync",
      );
      return MPFlutterWechatLaunchOption(
        path: result["path"],
        query: result["query"],
      );
    } else {
      return null;
    }
  }

  static MPFlutterWechatEnterOption? getEnterOption() {
    if (kIsMPFlutter) {
      final result = (context["wx"] as JSObject).callMethod(
        "getEnterOptionsSync",
      );
      return MPFlutterWechatEnterOption(
        path: result["path"],
        query: result["query"],
      );
    } else {
      return null;
    }
  }

  MPFlutterWechatAppDelegate({
    this.onLaunch,
    this.onShow,
    this.onHide,
    this.onShareAppMessage,
  }) {
    if (kIsMPFlutter) {
      try {
        addCallbackListenner();
      } catch (e) {
        print(e);
      }
    }
  }

  void addCallbackListenner() {
    final mpcbObject = JSObject("Object");
    mpcbObject["onShow"] = onShow;
    mpcbObject["onHide"] = onHide;
    if (onShareAppMessage != null) {
      mpcbObject["onShareAppMessage"] = (detail) async {
        final result = onShareAppMessage!(detail);
        final jsResult = JSObject("Object");
        result.forEach((key, value) {
          jsResult[key] = value;
        });
        return jsResult;
      };
    }
    context["wx"]["mpcb"] = mpcbObject;
  }
}
