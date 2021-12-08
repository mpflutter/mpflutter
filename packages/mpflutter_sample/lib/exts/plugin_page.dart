import 'package:flutter/widgets.dart';
import 'package:mpcore/mpcore.dart';
import 'package:mpcore/mpkit/mpkit.dart';
import 'package:mpflutter_plugin_template/mpflutter_plugin_template.dart';

class PluginPage extends StatelessWidget {
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
    return MPScaffold(
      name: 'Plugin',
      backgroundColor: Color.fromARGB(255, 236, 236, 236),
      body: ListView(
        children: [
          _renderBlock(Column(
            children: [
              _renderHeader('Tap to print the "Hello, World!" on console.'),
              GestureDetector(
                onTap: () {
                  TemplatePlugin.sayHello();
                },
                child: Container(
                  width: 100,
                  height: 100,
                  color: Colors.pink,
                ),
              ),
              SizedBox(height: 16),
            ],
          )),
          _renderBlock(Column(
            children: [
              _renderHeader('Tap to alert the value.'),
              GestureDetector(
                onTap: () async {
                  final value = await TemplatePlugin.getHello();
                  MPWebDialogs.alert(message: value);
                },
                child: Container(
                  width: 100,
                  height: 100,
                  color: Colors.pink,
                ),
              ),
              SizedBox(height: 16),
            ],
          )),
          _renderBlock(Column(
            children: [
              _renderHeader('Tap to listen event channel stream.'),
              GestureDetector(
                onTap: () async {
                  TemplatePlugin.installEventListener();
                },
                child: Container(
                  width: 100,
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
