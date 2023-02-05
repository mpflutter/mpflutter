import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:mpcore/mpcore.dart';

class CustomPaintPage extends StatefulWidget {
  @override
  State<CustomPaintPage> createState() => _CustomPaintPageState();
}

class _CustomPaintPageState extends State<CustomPaintPage> {
  MPDrawable? logoDrawable;

  @override
  void dispose() {
    logoDrawable?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    loadLogo();
  }

  void loadLogo() async {
    final drawable = await MPDrawable.fromNetworkImage(
      'https://mpflutter.com/zh/img/logo.png',
    );
    setState(() {
      logoDrawable = drawable;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MPScaffold(
      name: 'custom_paint',
      backgroundColor: Color.fromARGB(255, 236, 236, 236),
      body: Container(
        alignment: Alignment.center,
        child: Container(
          width: 500,
          height: 500,
          child: CustomPaint(
            size: Size(500, 500),
            painter: MyPainter()..logoDrawable = logoDrawable,
            child: RepaintBoundary(
              child: Container(),
            ),
          ),
        ),
      ),
    );
  }
}

class MyPainter extends CustomPainter {
  MPDrawable? logoDrawable;

  void drawChessboard(Canvas canvas, Rect rect) {
    var paint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill
      ..color = Color(0xFFDCC48C);
    canvas.drawRect(rect, paint);

    paint
      ..style = PaintingStyle.stroke
      ..color = Colors.black38
      ..strokeWidth = 1.0;

    for (int i = 0; i <= 15; ++i) {
      double dy = rect.top + rect.height / 15 * i;
      canvas.drawLine(Offset(rect.left, dy), Offset(rect.right, dy), paint);
    }

    for (int i = 0; i <= 15; ++i) {
      double dx = rect.left + rect.width / 15 * i;
      canvas.drawLine(Offset(dx, rect.top), Offset(dx, rect.bottom), paint);
    }
  }

  void drawPieces(Canvas canvas, Rect rect) {
    double eWidth = rect.width / 15;
    double eHeight = rect.height / 15;
    var paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.black;
    canvas.drawCircle(
      Offset(rect.center.dx - eWidth / 2, rect.center.dy - eHeight / 2),
      min(eWidth / 2, eHeight / 2) - 2,
      paint,
    );
    paint.color = Colors.white;
    canvas.drawCircle(
      Offset(rect.center.dx + eWidth / 2, rect.center.dy - eHeight / 2),
      min(eWidth / 2, eHeight / 2) - 2,
      paint,
    );
  }

  void drawLogo(Canvas canvas) {
    if (logoDrawable != null) {
      canvas.drawImageRect(
        logoDrawable!,
        Rect.fromLTWH(
          0,
          0,
          logoDrawable!.width.toDouble(),
          logoDrawable!.height.toDouble(),
        ),
        Rect.fromLTWH(20, 20, 88, 88),
        Paint()..color = Colors.white54,
      );
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    var rect = Offset.zero & size;
    drawChessboard(canvas, rect);
    drawPieces(canvas, rect);
    drawLogo(canvas);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
