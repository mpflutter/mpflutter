import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:mpcore/mpkit/mpkit.dart';

class IgnorePointerPage extends StatefulWidget {
  @override
  _IgnorePointerPageState createState() => _IgnorePointerPageState();
}

class _IgnorePointerPageState extends State<IgnorePointerPage> {
  Color color = Colors.pink;

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
      name: 'IgnorePointer',
      backgroundColor: Color.fromARGB(255, 236, 236, 236),
      body: ListView(
        children: [
          _renderBlock(Column(
            children: [
              _renderHeader('IgnorePointer wraps GestureDetector.'),
              IgnorePointer(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      color = Color.fromARGB(255, Random().nextInt(255),
                          Random().nextInt(255), Random().nextInt(255));
                    });
                  },
                  child: Container(
                    width: 100,
                    height: 100,
                    color: color,
                  ),
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
