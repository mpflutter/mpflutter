// Copyright 2023 The MPFlutter Authors. All rights reserved.
// Use of this source code is governed by a Apache License Version 2.0 that can be
// found in the LICENSE file.

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mpflutter_core/dev_app/dev_server.dart';

import '../mpflutter_core.dart';

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

  @override
  Widget build(BuildContext context) {
    if (!IsolateDevServer.shared.connected()) {
      return ConnectHostTips();
    }
    return widget.child;
  }
}

class ConnectHostTips extends StatefulWidget {
  const ConnectHostTips({
    super.key,
  });

  @override
  State<ConnectHostTips> createState() => _ConnectHostTipsState();
}

class _ConnectHostTipsState extends State<ConnectHostTips> {
  int currentStep = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(),
      home: Scaffold(
        body: ListView(
          children: [
            SizedBox(height: 22),
            ListTile(
              title: Align(
                alignment: Alignment.centerLeft,
                child: Icon(
                  Icons.connect_without_contact,
                  size: 48,
                  color: Colors.grey,
                ),
              ),
            ),
            ListTile(
              title: Text(
                "未连接到调试宿主",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            Divider(
              color: Colors.black.withOpacity(0.05),
              indent: 16,
              endIndent: 16,
            ),
            ListTile(title: Text('宿主连接方法')),
            Stepper(
              currentStep: currentStep,
              onStepContinue: () {
                setState(() {
                  currentStep = min(3, currentStep + 1);
                });
              },
              onStepCancel: () {
                setState(() {
                  currentStep = max(0, currentStep - 1);
                });
              },
              steps: [
                Step(
                  title: Text("构建 Dev Mode 产物"),
                  content:
                      Text('使用 dart scripts/build_wechat.dart --devmode 构建应用。'),
                ),
                Step(
                  title: Text("导入产物"),
                  content: Text(
                      '使用微信开发者工具，导入产物。                                       '),
                ),
                Step(
                  title: Text("运行产物"),
                  content: Text(
                      '微信开发者工具，直接在模拟器上运行，或者在微信扫码预览。                                       '),
                ),
                Step(
                  title: Text("注意"),
                  content: Text(
                      '不要同时在模拟器和真机上预览，请关掉其中一个。                                       '),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MPNavigatorObserverPrivate extends NavigatorObserver with ChangeNotifier {
  static Route? currentRoute;
  static MPNavigatorObserverPrivate? shared;

  MPNavigatorObserverPrivate() {
    shared = this;
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    if (!kIsMPFlutter) {
      return;
    }
    currentRoute = route;
    notifyListeners();
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    if (!kIsMPFlutter) {
      return;
    }
    currentRoute = previousRoute;
    notifyListeners();
  }
}
