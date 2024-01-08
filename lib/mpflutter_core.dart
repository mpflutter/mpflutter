// Copyright 2023 The MPFlutter Authors. All rights reserved.
// Use of this source code is governed by a Apache License Version 2.0 that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:mpflutter_core/mpflutter_memory.dart';
import 'package:mpflutter_core/mpflutter_splash.dart';
import 'package:window_manager/window_manager.dart';
import './dev_app/runApp.dart' if (dart.library.js) './wechat_app/runApp.dart';

export './logger.dart';
export 'wechat_app_delegate.dart';
export './mpflutter_platform_view.dart';

const bool kIsMPFlutter = bool.fromEnvironment(
  'mpflutter.library.core',
  defaultValue: false,
);
const bool kIsMPFlutterDevmode = bool.fromEnvironment(
  'mpflutter.library.devmode',
  defaultValue: false,
);

void runMPApp(Widget app) async {
  if (kIsMPFlutter) {
    if (kIsMPFlutterDevmode) {
      WidgetsFlutterBinding.ensureInitialized();
      await windowManager.ensureInitialized();
      WindowOptions windowOptions = WindowOptions(
        size: Size(414, 896),
      );
      windowManager.waitUntilReadyToShow(windowOptions, () async {
        await windowManager.show();
        await windowManager.focus();
      });
      runApp(MPApp(child: app));
    } else {
      setupMemoryManager();
      runApp(MPApp(child: app));
      MPFlutterSplashManager.hideSplash();
    }
  } else {
    runApp(app);
  }
}

class MPNavigatorObserver extends MPNavigatorObserverPrivate {
  static Route? get currentRoute {
    return MPNavigatorObserverPrivate.currentRoute;
  }
}
