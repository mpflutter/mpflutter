import 'package:flutter/widgets.dart';
import 'package:mpflutter_core/dev_app/dev_server.dart';

class MPApp extends StatefulWidget {
  final Widget child;

  const MPApp({super.key, required this.child});

  @override
  State<MPApp> createState() => _MPAppState();
}

class _MPAppState extends State<MPApp> {
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

class MPNavigatorObserverPrivate extends NavigatorObserver {}
