import 'package:flutter/widgets.dart';
import 'package:mpflutter/dev_app/dev_server.dart';

void runMPApp(Widget app) {
  runApp(MPDevApp(child: app));
}

bool kIsMiniProgram = true;

class MPDevApp extends StatefulWidget {
  final Widget child;

  const MPDevApp({super.key, required this.child});

  @override
  State<MPDevApp> createState() => _MPDevAppState();
}

class _MPDevAppState extends State<MPDevApp> {
  @override
  void dispose() {
    IsolateDevServer.shared.stop();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    IsolateDevServer.shared.start();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class MPNavigatorObserver extends NavigatorObserver {}
