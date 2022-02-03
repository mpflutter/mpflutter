import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

import 'package:mp_flutter_runtime/mp_flutter_runtime.dart';

void main() {
  runApp(const MaterialApp(
    home: SamplePage(),
  ));
}

class SamplePage extends StatefulWidget {
  const SamplePage({Key? key}) : super(key: key);

  @override
  _SamplePageState createState() => _SamplePageState();
}

class _SamplePageState extends State<SamplePage> {
  MPEngine? engine;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    initEngine();
  }

  void initEngine() async {
    if (engine == null) {
      final engine = MPEngine(flutterContext: context);
      // engine.initWithDebuggerServerAddr('127.0.0.1:9898');
      engine.initWithMpkData(
        (await rootBundle.load('assets/app.mpk')).buffer.asUint8List(),
      );
      await engine.start();
      setState(() {
        this.engine = engine;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (engine == null) return const SizedBox();
    return MPPage(engine: engine!);
  }
}
