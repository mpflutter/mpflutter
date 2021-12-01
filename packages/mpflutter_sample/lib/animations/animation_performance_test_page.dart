import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:mpcore/mpkit/mpkit.dart';

class AnimatedPerformanceTestPage extends StatelessWidget {
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
      name: 'Animated Performance',
      backgroundColor: Color.fromARGB(255, 236, 236, 236),
      body: ListView(
        children: [
          _renderBlock(Column(
            children: [
              _renderHeader('Rotation Box.'),
              RotationAnimation(),
              SizedBox(height: 16),
            ],
          )),
          _renderBlock(Column(
            children: [
              _renderHeader('Width Box.'),
              WidthAnimation(),
              SizedBox(height: 16),
            ],
          )),
          _renderBlock(Column(
            children: [
              _renderHeader('Rotation Box.'),
              RotationAnimation(),
              SizedBox(height: 16),
            ],
          )),
          _renderBlock(Column(
            children: [
              _renderHeader('Width Box.'),
              WidthAnimation(),
              SizedBox(height: 16),
            ],
          )),
          _renderBlock(Column(
            children: [
              _renderHeader('Rotation Box.'),
              RotationAnimation(),
              SizedBox(height: 16),
            ],
          )),
          _renderBlock(Column(
            children: [
              _renderHeader('Width Box.'),
              WidthAnimation(),
              SizedBox(height: 16),
            ],
          )),
          _renderBlock(Column(
            children: [
              _renderHeader('Rotation Box.'),
              RotationAnimation(),
              SizedBox(height: 16),
            ],
          )),
          _renderBlock(Column(
            children: [
              _renderHeader('Width Box.'),
              WidthAnimation(),
              SizedBox(height: 16),
            ],
          )),
        ],
      ),
    );
  }
}

class RotationAnimation extends StatefulWidget {
  @override
  State<RotationAnimation> createState() => _RotationAnimationState();
}

class _RotationAnimationState extends State<RotationAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      value: 0.0,
      duration: Duration(milliseconds: 3000),
    );
    _animationController.addListener(() {
      setState(() {});
    });
    _animationController.repeat(min: 0.0, max: 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: Key("animation"),
      child: Transform.rotate(
        angle: (_animationController.value * 360.0) * pi / 180.0,
        child: Container(
          width: 88,
          height: 88,
          color: Colors.pink,
          alignment: Alignment.topLeft,
          child: Container(
            width: 22,
            height: 22,
            color: Colors.yellow,
          ),
        ),
      ),
    );
  }
}

class WidthAnimation extends StatefulWidget {
  @override
  State<WidthAnimation> createState() => _WidthAnimationState();
}

class _WidthAnimationState extends State<WidthAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      value: 0.0,
      duration: Duration(milliseconds: 1000),
    );
    _animationController.addListener(() {
      setState(() {});
    });
    _animationController.repeat(min: 0.0, max: 1.0, reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: Key("animation"),
      child: Container(
        width: 288 * _animationController.value,
        height: 88,
        color: Colors.pink,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Flexible(
              flex: 1,
              child: Container(
                color: Colors.yellow,
              ),
            ),
            Flexible(
              flex: 2,
              child: Container(
                color: Colors.blue,
              ),
            )
          ],
        ),
      ),
    );
  }
}
