import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:mpcore/mpcore.dart';
import 'package:mpcore/mpkit/mpkit.dart';

class CustomPaintPage extends StatelessWidget {
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
            painter: MyPainter(),
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

  @override
  void paint(Canvas canvas, Size size) {
    final p = Path();
    // p.addOval(
    //   Rect.fromCenter(center: Offset(100, 100), width: 100, height: 100),
    // );
    p.addRRect(RRect.fromRectXY(Rect.fromLTWH(20, 20, 100, 100), 20, 20));
    final pa = Paint();
    pa.style = PaintingStyle.stroke;
    pa.color = Colors.red;
    pa.strokeWidth = 2;
    canvas.drawPath(p, pa);
    // var rect = Offset.zero & size;
    // drawChessboard(canvas, rect);
    // drawPieces(canvas, rect);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
