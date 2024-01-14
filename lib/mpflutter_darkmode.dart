// Copyright 2023 The MPFlutter Authors. All rights reserved.
// Use of this source code is governed by a Apache License Version 2.0 that can be
// found in the LICENSE file.

import 'package:mpflutter_core/mpflutter_core.dart';

import 'mpjs/mpjs.dart' as mpjs;

class MPFlutterDarkmodeManager {
  static bool isDarkmode() {
    if (!kIsMPFlutter) {
      return false;
    }
    mpjs.JSObject wx = mpjs.context["wx"];
    final result = wx.callMethod("getSystemInfoSync", [{}]);
    return result["theme"] == "dark";
  }

  static void addThemeListener(Function() callback) {
    if (!kIsMPFlutter) {
      return;
    }
    mpjs.JSObject wx = mpjs.context["wx"];
    wx.callMethod("onThemeChange", [
      (_) {
        callback();
      }
    ]);
  }
}
