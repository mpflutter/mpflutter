import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:mpcore/mpcore.dart';
import 'package:mpcore/mpkit/mpkit.dart';
import 'package:mpflutter_plugin_template/mpflutter_plugin_template.dart';

class PluginPage extends StatelessWidget {
  static bool methodChannelHandlerSetuped = false;

  static void setupMethodChannelHandler() {
    if (methodChannelHandlerSetuped) return;
    methodChannelHandlerSetuped = true;
    TemplatePlugin.methodChannel.setMethodCallHandler((call) async {
      if (call.method == 'getCallerName') {
        return 'Flutter';
      }
      throw 'NOT IMPLEMENTED';
    });
  }

  Widget _renderBlock(Widget child) {
    return Padding(
      padding: EdgeInsets.all(12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          color: Colors.white,
          child: child,
        ),
      ),
    );
  }

  Widget _renderHeader(String title) {
    return Container(
      height: 48,
      padding: EdgeInsets.only(left: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    setupMethodChannelHandler();
    return MPScaffold(
      name: 'Plugin',
      backgroundColor: Color.fromARGB(255, 236, 236, 236),
      body: ListView(
        children: [
          _renderBlock(Column(
            children: [
              _renderHeader(
                  'The device name will print to the box (MethodChannel).'),
              Container(
                width: 300,
                height: 100,
                color: Colors.pink,
                child: Center(
                  child: FutureBuilder(
                    future: (() async {
                      return TemplatePlugin.getDeivceName();
                    })(),
                    builder: (context, state) {
                      if (!state.hasData) return Container();
                      return Text(
                        state.data as String,
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      );
                    },
                  ),
                ),
              ),
              SizedBox(height: 16),
            ],
          )),
          _renderBlock(Column(
            children: [
              _renderHeader('The date will update per second (EventChannel).'),
              _EventChannelSample(),
              SizedBox(height: 16),
            ],
          )),
          _renderBlock(Column(
            children: [
              _renderHeader('The foo view with text (PlatformView)'),
              _PlatformViewSample(),
              SizedBox(height: 16),
            ],
          )),
          _renderBlock(Column(
            children: [
              _renderHeader('The mpjs template'),
              GestureDetector(
                onTap: () async {
                  final result = await MPJS.evalTemplate('foo', ['Pony']);
                  print(result);
                },
                child: Container(
                  width: 300,
                  height: 100,
                  color: Colors.pink,
                ),
              ),
              SizedBox(height: 16),
            ],
          )),
        ],
      ),
    );
  }
}

class _EventChannelSample extends StatefulWidget {
  const _EventChannelSample({
    Key? key,
  }) : super(key: key);

  @override
  State<_EventChannelSample> createState() => _EventChannelSampleState();
}

class _EventChannelSampleState extends State<_EventChannelSample> {
  final eventChannel = EventChannel('com.mpflutter.templateEventChannel');
  var value = '';
  StreamSubscription? streamSubscription;

  @override
  void dispose() {
    if (streamSubscription != null) {
      streamSubscription?.cancel();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    startListen();
  }

  void startListen() {
    streamSubscription = eventChannel.receiveBroadcastStream().listen((data) {
      setState(() {
        value = data;
      });
    });
  }

  void stopListen() {
    if (streamSubscription != null) {
      streamSubscription?.cancel();
      streamSubscription = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (streamSubscription == null) {
          startListen();
        } else {
          stopListen();
        }
      },
      child: Container(
        width: 300,
        height: 100,
        color: Colors.pink,
        child: Center(
          child: Text(
            value,
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
    );
  }
}

class _PlatformViewSample extends StatefulWidget {
  const _PlatformViewSample({
    Key? key,
  }) : super(key: key);

  @override
  State<_PlatformViewSample> createState() => _PlatformViewSampleState();
}

class _PlatformViewSampleState extends State<_PlatformViewSample> {
  String text = 'Hello, Foo.';

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 5)).then((value) {
      setState(() {
        text = 'Foo changed.';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 100,
      child: Center(
        child: TemplateFooView(
          text: text,
        ),
      ),
    );
  }
}
