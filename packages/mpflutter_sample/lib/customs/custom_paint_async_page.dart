import 'package:flutter/widgets.dart';
import 'package:mpcore/mpcore.dart';
import 'package:mpcore/mpkit/mpkit.dart';

class CustomPaintAsyncPage extends StatefulWidget {
  @override
  State<CustomPaintAsyncPage> createState() => _CustomPaintAsyncPageState();
}

class _CustomPaintAsyncPageState extends State<CustomPaintAsyncPage> {
  MPDrawable? logoDrawable;

  @override
  void dispose() {
    logoDrawable?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MPScaffold(
      name: 'custom_paint_async',
      body: Container(
        alignment: Alignment.center,
        child: Container(
          width: 300,
          height: 300,
          color: Colors.black,
          child: CustomPaint(
            size: Size(300, 300),
            painter: MyPainter(),
          ),
        ),
      ),
    );
  }
}

class MyPainter extends CustomPainter {
  @override
  bool isAsyncPainter() {
    return true;
  }

  @override
  void paint(Canvas canvas, Size size) {}

  @override
  Future paintAsync(Canvas canvas, Size size) async {
    final textPainter = MPTextPainter();
    textPainter.text = TextSpan(
      text: 'Hello, World!',
      style: TextStyle(
        fontSize: 32,
        color: Colors.white,
      ),
    );
    await textPainter.layout(maxWidth: 300);
    canvas.drawRect(
      Rect.fromLTWH(
        (size.width - textPainter.size.width) / 2.0,
        (size.height - textPainter.size.height) / 2.0,
        textPainter.size.width,
        textPainter.size.height,
      ),
      Paint()..color = Colors.red,
    );
    textPainter.paint(
      canvas,
      Offset(
          (size.width - textPainter.size.width) / 2.0,
          (size.height - textPainter.size.height) / 2.0 +
              textPainter.size.height / 2.0),
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
