// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of dart.ui;

Future<void> webOnlyInitializePlatform({
  dynamic? assetManager,
}) {
  final Future<void> initializationFuture =
      _initializePlatform(assetManager: assetManager);
  return initializationFuture;
}

Future<void> _initializePlatform({
  dynamic? assetManager,
}) async {
  _webOnlyIsInitialized = true;
}

bool _webOnlyIsInitialized = false;

bool get webOnlyIsInitialized => _webOnlyIsInitialized;

Future<void> webOnlySetAssetManager(dynamic assetManager) async {}

bool get debugEmulateFlutterTesterEnvironment =>
    _debugEmulateFlutterTesterEnvironment;

set debugEmulateFlutterTesterEnvironment(bool value) {}

bool _debugEmulateFlutterTesterEnvironment = false;
dynamic get webOnlyAssetManager => null;
dynamic get webOnlyFontCollection => null;
