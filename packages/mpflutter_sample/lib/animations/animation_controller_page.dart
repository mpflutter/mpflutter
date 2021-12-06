import 'package:flutter/widgets.dart';
import 'package:mpcore/mpkit/mpkit.dart';

class AnimationControllerPage extends StatelessWidget {
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
      name: 'AnimationController',
      backgroundColor: Color.fromARGB(255, 236, 236, 236),
      body: ListView(
        children: [
          _renderBlock(Column(
            children: [
              _renderHeader('Animating number.'),
              AnimatingNumber(),
              SizedBox(height: 16),
            ],
          )),
        ],
      ),
    );
  }
}

class AnimatingNumber extends StatefulWidget {
  @override
  _AnimatingNumberState createState() => _AnimatingNumberState();
}

class _AnimatingNumberState extends State<AnimatingNumber>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  String textValue = "0";

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
        vsync: this, lowerBound: 0, upperBound: 100, value: 0);
    animationController.addListener(() {
      String newTextValue = animationController.value.toStringAsFixed(0);
      if (newTextValue != textValue) {
        setState(() {
          textValue = newTextValue;
        });
      }
    });
    startAnimation();
  }

  void startAnimation() {
    animationController.repeat(min: 0, max: 100, period: Duration(seconds: 10));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      color: Colors.pink,
      child: Center(
        child: Container(
          width: 44,
          height: 18 * 1.4375,
          child: MPText(
            textValue,
            style: TextStyle(
              fontSize: 18,
              color: Colors.yellow,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            noMeasure: true,
          ),
        ),
      ),
    );
  }
}
