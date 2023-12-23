import 'package:flutter/material.dart';
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
    IsolateDevServer.shared.addListener(() {
      setState(() {});
    });
  }

  Widget renderDisconnected() {
    return Container(
      color: Colors.blue,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '未能连接到调试宿主',
              style: TextStyle(
                fontSize: 20,
                color: Colors.yellow,
                fontWeight: FontWeight.bold,
              ),
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),
            Text(
              '应用将在宿主连接后恢复',
              style: TextStyle(
                fontSize: 12,
                color: Colors.yellow.withOpacity(0.8),
                fontWeight: FontWeight.bold,
              ),
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!IsolateDevServer.shared.connected()) {
      return renderDisconnected();
    }
    return widget.child;
  }
}

class MPNavigatorObserverPrivate extends NavigatorObserver {}
