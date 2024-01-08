// Copyright 2023 The MPFlutter Authors. All rights reserved.
// Use of this source code is governed by a Apache License Version 2.0 that can be
// found in the LICENSE file.

import 'dart:async';

import 'mpjs/mpjs.dart' as mpjs;

class MPFlutterSplashManager {
  static bool _displayingSplash = true;

  static void displaySplash() {
    _displayingSplash = true;
    mpjs.JSObject self = mpjs.context["FlutterHostView"]["shared"]["self"];
    self.callMethod("setData", [
      {
        "readyToDisplay": false,
      }
    ]);
  }

  static void hideSplash() {
    _displayingSplash = false;
    Timer(Duration(milliseconds: 500), () {
      if (_displayingSplash) return;
      mpjs.JSObject self = mpjs.context["FlutterHostView"]["shared"]["self"];
      self.callMethod("setData", [
        {
          "readyToDisplay": true,
        }
      ]);
    });
  }
}
