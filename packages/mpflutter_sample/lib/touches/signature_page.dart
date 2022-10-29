import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:mpcore/mpkit/mpkit.dart';

class SignaturePage extends StatefulWidget {
  @override
  _SignaturePageState createState() => _SignaturePageState();
}

class _SignaturePageState extends State<SignaturePage> {
  final customPaintKey = GlobalKey();
  final List<Offset> points = [];
  Uint8List? savedData;

  @override
  Widget build(BuildContext context) {
    return MPScaffold(
      name: 'Signature',
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Container(
            width: 300,
            height: 300,
            color: Colors.white,
            child: GestureDetector(
              onPanStart: (e) {
                setState(() {
                  points.add(e.localPosition);
                });
              },
              onPanUpdate: (e) {
                setState(() {
                  points.add(e.localPosition);
                });
              },
              onPanEnd: (e) {
                points.add(Offset(-1, -1));
              },
              child: IgnorePointer(
                child: CustomPaint(
                  key: customPaintKey,
                  painter: _SignaturePainter(points),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () async {
              try {
                final result = await fetchImageFromCustomPaint(customPaintKey);
                setState(() {
                  savedData = result;
                });
              } catch (e) {
                print(e);
              }
            },
            child: Container(
              width: 88,
              height: 44,
              color: Colors.pink,
            ),
          ),
          savedData != null
              ? Container(
                  color: Colors.yellow,
                  child: Image.memory(
                    savedData!,
                    width: 100,
                    height: 100,
                  ),
                )
              : SizedBox(),
        ],
      ),
    );
  }
}

class _SignaturePainter extends CustomPainter {
  final List<Offset> points;

  _SignaturePainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    Offset? lastPoint;
    points.forEach((element) {
      if (element.dx < 0 && element.dy < 0) {
        lastPoint = null;
        return;
      }
      if (lastPoint != null) {
        canvas.drawLine(lastPoint!, element, paint);
      }
      lastPoint = element;
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
