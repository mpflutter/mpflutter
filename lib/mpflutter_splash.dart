// Copyright 2023 The MPFlutter Authors. All rights reserved.
// Use of this source code is governed by a Apache License Version 2.0 that can be
// found in the LICENSE file.

import 'mpjs/mpjs.dart' as mpjs;

class MPFlutterSplashManager {
  static void displaySplash() {
    mpjs.JSObject self = mpjs.context["FlutterHostView"]["shared"]["self"];
    self.callMethod("setData", [
      {
        "readyToDisplay": false,
      }
    ]);
  }

  static void hideSplash() {
    mpjs.JSObject self = mpjs.context["FlutterHostView"]["shared"]["self"];
    self.callMethod("setData", [
      {
        "readyToDisplay": true,
      }
    ]);
  }
}
