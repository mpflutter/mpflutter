import 'package:flutter/widgets.dart';
import 'package:mpcore/mpcore.dart';
import 'package:mpcore/mpkit/mpkit.dart';

class DialogsPage extends StatelessWidget {
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
      name: 'Dialogs',
      backgroundColor: Color.fromARGB(255, 236, 236, 236),
      body: ListView(
        children: [
          _renderBlock(Column(
            children: [
              _renderHeader('Alert - tap yellow box to show alert view.'),
              AlertSample(),
              SizedBox(height: 16),
            ],
          )),
          _renderBlock(Column(
            children: [
              _renderHeader('Confirm - tap yellow box to show confirm view.'),
              ConfirmSample(),
              SizedBox(height: 16),
            ],
          )),
          _renderBlock(Column(
            children: [
              _renderHeader('Prompt'),
              PromptSample(),
              SizedBox(height: 16),
            ],
          )),
          _renderBlock(Column(
            children: [
              _renderHeader('ActionSheet'),
              ActionSheetSample(),
              SizedBox(height: 16),
            ],
          )),
          _renderBlock(Column(
            children: [
              _renderHeader('showToast loading'),
              ToastSample(),
              SizedBox(height: 16),
            ],
          )),
        ],
      ),
    );
  }
}

class AlertSample extends StatefulWidget {
  @override
  _AlertSampleState createState() => _AlertSampleState();
}

class _AlertSampleState extends State<AlertSample> {
  Color color = Colors.yellow;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      color: Colors.pink,
      child: Center(
        child: GestureDetector(
          onTap: () async {
            await MPWebDialogs.alert(message: 'This is alert message.');
            setState(() {
              color = Colors.blue;
            });
          },
          child: Container(
            width: 50,
            height: 50,
            color: color,
          ),
        ),
      ),
    );
  }
}

class ConfirmSample extends StatefulWidget {
  @override
  _ConfirmSampleState createState() => _ConfirmSampleState();
}

class _ConfirmSampleState extends State<ConfirmSample> {
  Color color = Colors.yellow;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      color: Colors.pink,
      child: Center(
        child: GestureDetector(
          onTap: () async {
            final confirmed = await MPWebDialogs.confirm(
              message:
                  'This is confirm message, click confirm and the yellow box will turn to black.',
            );
            if (confirmed) {
              setState(() {
                color = Colors.black;
              });
            }
          },
          child: Container(
            width: 50,
            height: 50,
            color: color,
          ),
        ),
      ),
    );
  }
}

class PromptSample extends StatefulWidget {
  @override
  _PromptSampleState createState() => _PromptSampleState();
}

class _PromptSampleState extends State<PromptSample> {
  String text = "Tap here to show prompt.";

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: GestureDetector(
        onTap: () async {
          final result = await MPWebDialogs.prompt(
            message: 'Input the text.',
            defaultValue: 'Default value',
            context: context,
          );
          if (result != null) {
            setState(() {
              text = result;
            });
          }
        },
        child: Container(
          height: 100,
          color: Colors.pink,
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ActionSheetSample extends StatefulWidget {
  @override
  _ActionSheetSampleState createState() => _ActionSheetSampleState();
}

class _ActionSheetSampleState extends State<ActionSheetSample> {
  String text = "Tap here to show action sheet.";

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: GestureDetector(
        onTap: () async {
          final items = ['A - Apple', 'B - Boy', 'C - Cat'];
          final result = await MPWebDialogs.actionSheet(
            items: items,
          );
          if (result != null) {
            setState(() {
              text = items[result];
            });
          }
        },
        child: Container(
          height: 100,
          color: Colors.pink,
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ToastSample extends StatefulWidget {
  @override
  _ToastSampleState createState() => _ToastSampleState();
}

class _ToastSampleState extends State<ToastSample> {
  Color color = Colors.yellow;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      color: Colors.pink,
      child: Center(
        child: GestureDetector(
          onTap: () async {
            MPWebDialogs.showToast(
              title: '加载中',
              icon: ToastIcon.loading,
              duration: Duration(seconds: 60),
              mask: true,
            );
            await Future.delayed(Duration(seconds: 5));
            MPWebDialogs.hideToast();
          },
          child: Container(
            width: 50,
            height: 50,
            color: color,
          ),
        ),
      ),
    );
  }
}
