import 'package:flutter/widgets.dart';
import './dev_app/runApp.dart' if (dart.library.js) './wechat_app/runApp.dart';

export './logger.dart';
export './wechat_callbacks.dart';

bool kIsMPFlutter = bool.fromEnvironment(
  'mpflutter.library.core',
  defaultValue: false,
);
bool kIsMPFlutterDebugger = bool.fromEnvironment(
  'mpflutter.library.debugger',
  defaultValue: false,
);

void runMPApp(Widget app) {
  if (kIsMPFlutter) {
    runApp(MPApp(child: app));
  } else {
    runApp(app);
  }
}

class MPNavigatorObserver extends MPNavigatorObserverPrivate {}
