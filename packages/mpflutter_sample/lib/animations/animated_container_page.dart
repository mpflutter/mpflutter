import 'package:flutter/widgets.dart';
import 'package:mpcore/mpkit/mpkit.dart';

class AnimatedContainerPage extends StatelessWidget {
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
      name: 'Animated Container',
      backgroundColor: Color.fromARGB(255, 236, 236, 236),
      body: ListView(
        children: [
          _renderBlock(Column(
            children: [
              _renderHeader('Tap to drive the yellow box changed.'),
              AnimatingContainer(),
              SizedBox(height: 16),
            ],
          )),
        ],
      ),
    );
  }
}

class AnimatingContainer extends StatefulWidget {
  @override
  _AnimatingContainerState createState() => _AnimatingContainerState();
}

class _AnimatingContainerState extends State<AnimatingContainer> {
  double boxSize = 40.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      color: Colors.pink,
      child: Center(
        child: GestureDetector(
          onTap: () {
            setState(() {
              if (boxSize > 40) {
                boxSize = 40;
              } else {
                boxSize = 80;
              }
            });
          },
          child: AnimatedContainer(
            width: boxSize,
            height: boxSize,
            duration: Duration(milliseconds: 1000),
            curve: Curves.ease,
            child: AnimatedOpacity(
              opacity: boxSize == 40 ? 1.0 : 0.5,
              duration: Duration(milliseconds: 1000),
              child: AnimatedContainer(
                transform: Matrix4.rotationZ(boxSize == 40 ? 45.0 : 0.0),
                duration: Duration(milliseconds: 1000),
                curve: Curves.ease,
                color: boxSize == 40 ? Colors.blue : Colors.yellow,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
