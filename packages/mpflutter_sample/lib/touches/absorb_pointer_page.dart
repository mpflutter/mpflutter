import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:mpcore/mpkit/mpkit.dart';

class AbsorbPointerPage extends StatefulWidget {
  @override
  _AbsorbPointerPageState createState() => _AbsorbPointerPageState();
}

class _AbsorbPointerPageState extends State<AbsorbPointerPage> {
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
      height: 66,
      padding: EdgeInsets.only(left: 12),
      child: Text(
        title,
        style: TextStyle(fontSize: 14, color: Colors.black54),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MPScaffold(
      name: 'AbsorbPointer',
      backgroundColor: Color.fromARGB(255, 236, 236, 236),
      body: ListView(
        children: [
          _renderBlock(Column(
            children: [
              _renderHeader(
                  'AbsorbPointer wraps yellow box, yellow box catches all touches.'),
              GestureDetector(
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
                  child: Center(
                    child: AbsorbPointer(
                      child: Container(
                        width: 44,
                        height: 44,
                        color: Colors.yellow,
                      ),
                    ),
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
