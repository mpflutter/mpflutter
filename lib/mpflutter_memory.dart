// Copyright 2023 The MPFlutter Authors. All rights reserved.
// Use of this source code is governed by a Apache License Version 2.0 that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'mpjs/mpjs.dart' as mpjs;

void setupMemoryManager() {
  WidgetsFlutterBinding.ensureInitialized();
  PaintingBinding.instance.imageCache.maximumSize = 100;
  PaintingBinding.instance.imageCache.maximumSizeBytes = 30 << 20;
  (mpjs.context["wx"] as mpjs.JSObject).callMethod("onMemoryWarning", [
    (res) {
      PaintingBinding.instance.imageCache.clear();
    }
  ]);
}
