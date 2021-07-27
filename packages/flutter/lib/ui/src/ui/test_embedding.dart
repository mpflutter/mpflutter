// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// TODO(flutter_web): the Web-only API below need to be cleaned up.

part of dart.ui;

Future<void>? _testPlatformInitializedFuture;

Future<dynamic> ensureTestPlatformInitializedThenRunTest(
    dynamic Function() body) async {
  return null;
}

// TODO(yjbanov): can we make this late non-null? See https://github.com/dart-lang/sdk/issues/42214
Future<void>? _platformInitializedFuture;

Future<void> webOnlyInitializeTestDomRenderer(
    {double devicePixelRatio = 3.0}) async {}
