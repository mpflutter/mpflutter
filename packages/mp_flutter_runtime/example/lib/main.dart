import 'package:flutter/material.dart';
import 'dart:async';

import 'package:mp_flutter_runtime/mp_flutter_runtime.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final engine = MPEngine();

  @override
  void initState() {
    super.initState();
    engine.initWithDebuggerServerAddr('127.0.0.1:9898');
    engine.start();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MPPage(
        engine: engine,
      ),
    );
  }
}
