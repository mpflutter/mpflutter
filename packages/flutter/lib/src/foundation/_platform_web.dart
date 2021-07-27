// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// import 'dart:html' as html;
import 'platform.dart' as platform;

/// The dart:html implementation of [platform.defaultTargetPlatform].
platform.TargetPlatform get defaultTargetPlatform {
  // To get a better guess at the targetPlatform we need to be able to reference
  // the window, but that won't be available until we fix the platforms
  // configuration for Flutter.
  platform.TargetPlatform result = _browserPlatform();
  if (platform.debugDefaultTargetPlatformOverride != null)
    result = platform.debugDefaultTargetPlatformOverride!;
  return result;
}

platform.TargetPlatform _browserPlatform() {
  return platform.TargetPlatform.macOS;
}
