import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:mpcore/mpkit/mpkit.dart';

class GestureDetectorPage extends StatefulWidget {
  @override
  _GestureDetectorPageState createState() => _GestureDetectorPageState();
}

class _GestureDetectorPageState extends State<GestureDetectorPage> {
  Color color = Colors.pink;
  Color colorNested = Colors.yellow;
  Color color2 = Colors.pink;
  int tapCount = 0;

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
      name: 'GestureDetector',
      backgroundColor: Color.fromARGB(255, 236, 236, 236),
      body: ListView(
        children: [
          _renderBlock(Column(
            children: [
              _renderHeader('GestureDetector handle single tap.'),
              GestureDetector(
                onTap: () {
                  setState(() {
                    color = Color.fromARGB(255, Random().nextInt(255),
                        Random().nextInt(255), Random().nextInt(255));
                    tapCount++;
                  });
                },
                child: Container(
                  width: 200,
                  height: 200,
                  color: color,
                  child: Center(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          colorNested = Color.fromARGB(
                              255,
                              Random().nextInt(255),
                              Random().nextInt(255),
                              Random().nextInt(255));
                          tapCount++;
                        });
                      },
                      child: Container(
                        width: 100,
                        height: 100,
                        color: colorNested,
                        child: Center(
                          child: Text(
                            tapCount.toString(),
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
            ],
          )),
          _renderBlock(Column(
            children: [
              _renderHeader('GestureDetector handle long-press.'),
              _LongPressSample(),
              SizedBox(height: 16),
            ],
          )),
          _renderBlock(Column(
            children: [
              _renderHeader('GestureDetector handle pan.'),
              _PanSample(),
              SizedBox(height: 16),
            ],
          )),
        ],
      ),
    );
  }
}

class _LongPressSample extends StatefulWidget {
  const _LongPressSample({
    Key? key,
  }) : super(key: key);

  @override
  State<_LongPressSample> createState() => _LongPressSampleState();
}

class _LongPressSampleState extends State<_LongPressSample> {
  Color color = Colors.yellow;
  double opacity = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (e) {
        setState(() {
          color = Colors.pink;
        });
      },
      onLongPressMoveUpdate: (e) {
        setState(() {
          opacity = max(0.0, min(1.0, e.globalPosition.dy / 500.0));
        });
      },
      onLongPressEnd: (e) {
        setState(() {
          color = Colors.yellow;
        });
      },
      child: Opacity(
        opacity: opacity,
        child: Container(
          width: 200,
          height: 200,
          color: color,
        ),
      ),
    );
  }
}

class _PanSample extends StatefulWidget {
  const _PanSample({
    Key? key,
  }) : super(key: key);

  @override
  State<_PanSample> createState() => _PanSampleState();
}

class _PanSampleState extends State<_PanSample> {
  Color color = Colors.yellow;
  double opacity = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (e) {
        setState(() {
          color = Colors.pink;
        });
      },
      onPanUpdate: (e) {
        setState(() {
          opacity = max(0.0, min(1.0, e.globalPosition.dy / 500.0));
        });
      },
      onPanEnd: (e) {
        setState(() {
          color = Colors.yellow;
        });
      },
      child: Opacity(
        opacity: opacity,
        child: Container(
          width: 200,
          height: 200,
          color: color,
        ),
      ),
    );
  }
}
