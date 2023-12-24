import 'package:flutter/widgets.dart';
import 'package:window_manager/window_manager.dart';
import './dev_app/runApp.dart' if (dart.library.js) './wechat_app/runApp.dart';

export './logger.dart';
export './wechat_callbacks.dart';
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
    }
    runApp(MPApp(child: app));
  } else {
    runApp(app);
  }
}

class MPNavigatorObserver extends MPNavigatorObserverPrivate {}
