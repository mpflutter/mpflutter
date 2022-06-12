import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:mp_flutter_runtime/mp_flutter_runtime.dart';

void main() {
  MPPluginRegister.registerChannel(
    'com.mpflutter.templateMethodChannel',
    () => MPTemplateMethodChannel(),
  );
  MPPluginRegister.registerChannel(
    'com.mpflutter.templateEventChannel',
    () => MPTemplateEventChannel(),
  );
  MPPluginRegister.registerPlatformView(
    'com.mpflutter.templateFooView',
    (key, data, parentData, componentFactory) =>
        TemplateFooView(key, data, parentData, componentFactory),
  );
  runApp(MaterialApp(
    home: Builder(builder: (context) {
      // return MediaQuery(
      //   data: MediaQuery.of(context).copyWith(
      //     platformBrightness: Brightness.dark,
      //   ),
      //   child: SamplePage(),
      // );
      return SamplePage();
    }),
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
      engine.initWithDebuggerServerAddr('127.0.0.1:9898');
      // engine.initWithMpkData(
      //   (await rootBundle.load('assets/app.mpk')).buffer.asUint8List(),
      // );
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

class MPTemplateMethodChannel extends MPMethodChannel {
  MPTemplateMethodChannel() : super('com.mpflutter.templateMethodChannel');

  @override
  Future? onMethodCall(String method, params) async {
    if (method == 'getDeviceName') {
      final who = await invokeMethod('getCallerName');
      return '$who on Flutter';
    } else {
      throw 'NOT IMPLEMENTED';
    }
  }
}

class MPTemplateEventChannel extends MPEventChannel {
  Timer? timer;

  MPTemplateEventChannel() : super('com.mpflutter.templateEventChannel');

  @override
  void onListen(params, Function(dynamic data) eventSink) {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      eventSink(DateTime.now().toIso8601String());
    });
  }

  @override
  void onCancel(params) {
    timer?.cancel();
    timer = null;
  }
}

class TemplateFooView extends MPPlatformView {
  TemplateFooView(
    Key? key,
    Map? data,
    Map? parentData,
    dynamic componentFactory,
  ) : super(
          key: key,
          data: data,
          parentData: parentData,
          componentFactory: componentFactory,
        );

  @override
  Widget builder(BuildContext context) {
    return GestureDetector(
      onTap: () {
        invokeMethod('xxx', {'yyy': 'kkk'});
      },
      child: Container(
        color: Colors.yellow,
        child: Center(
          child: Text(
            getStringFromAttributes(context, 'text') ?? '',
          ),
        ),
      ),
    );
  }
}
