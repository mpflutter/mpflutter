part of dart.ui;

class MockPath implements Path {
  factory MockPath.from() {
    return MockPath();
  }

  List<Map> _commands = [];
  Function(Offset)? waitingArcToPoint;
  Offset _lastPointFromLineStart = Offset(0.0, 0.0);
  Offset _lastPoint = Offset(0.0, 0.0);

  MockPath();

  Map toJson() {
    return {'commands': _commands};
  }

  PathFillType get fillType => PathFillType.nonZero;
  set fillType(PathFillType value) {}

  void moveTo(double x, double y) {
    _commands.add({'action': 'moveTo', 'x': x, 'y': y});
    _lastPoint = Offset(x, y);
  }

  void relativeMoveTo(double dx, double dy) {
    final nextPoint = _lastPoint.translate(dx, dy);
    moveTo(nextPoint.dx, nextPoint.dy);
  }

  void lineTo(double x, double y) {
    if (waitingArcToPoint != null) {
      waitingArcToPoint!(Offset(x, y));
      waitingArcToPoint = null;
    }
    _lastPointFromLineStart = _lastPoint;
    _commands.add({'action': 'lineTo', 'x': x, 'y': y});
    _lastPoint = Offset(x, y);
  }

  void relativeLineTo(double dx, double dy) {
    final nextPoint = _lastPoint.translate(dx, dy);
    lineTo(nextPoint.dx, nextPoint.dy);
  }

  void quadraticBezierTo(double x1, double y1, double x2, double y2) {
    _commands.add({
      'action': 'quadraticBezierTo',
      'x1': x1,
      'y1': y1,
      'x2': x2,
      'y2': y2
    });
    _lastPoint = Offset(x2, y2);
  }

  void relativeQuadraticBezierTo(double x1, double y1, double x2, double y2) {
    final nextPoint1 = _lastPoint.translate(x1, y1);
    final nextPoint2 = _lastPoint.translate(x2, y2);
    quadraticBezierTo(
      nextPoint1.dx,
      nextPoint1.dy,
      nextPoint2.dx,
      nextPoint2.dy,
    );
  }

  void cubicTo(
      double x1, double y1, double x2, double y2, double x3, double y3) {
    _commands.add({
      'action': 'cubicTo',
      'x1': x1,
      'y1': y1,
      'x2': x2,
      'y2': y2,
      'x3': x3,
      'y3': y3,
    });
    _lastPoint = Offset(x3, y3);
  }

  void relativeCubicTo(
      double x1, double y1, double x2, double y2, double x3, double y3) {
    final nextPoint1 = _lastPoint.translate(x1, y1);
    final nextPoint2 = _lastPoint.translate(x2, y2);
    final nextPoint3 = _lastPoint.translate(x3, y3);
    cubicTo(
      nextPoint1.dx,
      nextPoint1.dy,
      nextPoint2.dx,
      nextPoint2.dy,
      nextPoint3.dx,
      nextPoint3.dy,
    );
  }

  void conicTo(double x1, double y1, double x2, double y2, double w) {}
  void relativeConicTo(double x1, double y1, double x2, double y2, double w) {}

  void arcTo(
      Rect rect, double startAngle, double sweepAngle, bool forceMoveTo) {
    _commands.add({
      'action': 'arcTo',
      'x': rect.center.dx,
      'y': rect.center.dy,
      'width': rect.width,
      'height': rect.height,
      'startAngle': startAngle,
      'sweepAngle': sweepAngle,
      'forceMoveTo': forceMoveTo,
    });
  }

  void arcToPoint(
    Offset arcEnd, {
    Radius radius = Radius.zero,
    double rotation = 0.0,
    bool largeArc = false,
    bool clockwise = true,
  }) {
    final pt1 = _lastPointFromLineStart;
    final pt2 = _lastPoint;
    final pt3 = Offset(arcEnd.dx, arcEnd.dy);
    _lastPoint = pt3;
    waitingArcToPoint = (pt4) {
      var controlPoint = getControllPoint(pt1, pt2, pt3, pt4);
      if (controlPoint.dx.isInfinite || controlPoint.dy.isInfinite) {
        return;
      }
      _commands.add({
        'action': 'arcToPoint',
        'arcControlX': controlPoint.dx,
        'arcControlY': controlPoint.dy,
        'arcEndX': arcEnd.dx,
        'arcEndY': arcEnd.dy,
        'radiusX': radius.x,
        'radiusY': radius.y,
        'rotation': rotation,
        'largeArc': largeArc,
        'clockwise': clockwise,
      });
    };
  }

  Offset getControllPoint(Offset pt1, Offset pt2, Offset pt3, Offset pt4) {
    final a1 = (pt1.dy - pt2.dy) / (pt1.dx - pt2.dx);
    final b1 = pt1.dy - (a1 * pt1.dx);
    final a2 = (pt3.dy - pt4.dy) / (pt3.dx - pt4.dx);
    final b2 = pt3.dy - (a2 * pt3.dx);
    final x = (() {
      if (pt1.dx == pt2.dx) {
        return pt1.dx;
      } else if (pt3.dx == pt4.dx) {
        return pt3.dx;
      }
      return -(b1 - b2) / (a1 - a2);
    })();
    final y = (() {
      if (a1 == 0.0) {
        return b1;
      } else if (a2 == 0.0) {
        return b2;
      }
      return a1 * x + b1;
    })();
    return Offset(x, y);
  }

  void relativeArcToPoint(
    Offset arcEndDelta, {
    Radius radius = Radius.zero,
    double rotation = 0.0,
    bool largeArc = false,
    bool clockwise = true,
  }) {
    final nextPoint = _lastPoint.translate(arcEndDelta.dx, arcEndDelta.dy);
    arcToPoint(
      nextPoint,
      radius: radius,
      rotation: rotation,
      largeArc: largeArc,
      clockwise: clockwise,
    );
  }

  void addRect(Rect rect) {
    moveTo(rect.left, rect.top);
    lineTo(rect.right, rect.top);
    lineTo(rect.right, rect.bottom);
    lineTo(rect.left, rect.bottom);
    close();
  }

  void addOval(Rect oval) {
    arcTo(oval, 0, math.pi, false);
    arcTo(oval, math.pi, math.pi, false);
  }

  void addArc(Rect oval, double startAngle, double sweepAngle) {
    arcTo(oval, startAngle, sweepAngle, false);
  }

  void addPolygon(List<Offset> points, bool close) {}

  void addRRect(RRect rrect) {
    moveTo(rrect.left + rrect.tlRadius.x, rrect.top);
    if (rrect.left + rrect.tlRadius.x == rrect.right - rrect.trRadius.x) {
      arcTo(
        Rect.fromCircle(
          center: Offset(
            rrect.right - rrect.trRadius.x,
            rrect.top + rrect.trRadius.x,
          ),
          radius: rrect.trRadius.x,
        ),
        -math.pi * 0.5,
        math.pi * 0.5,
        false,
      );
    } else {
      lineTo(rrect.right - rrect.trRadius.x, rrect.top);
      arcToPoint(
        Offset(rrect.right, rrect.top + rrect.trRadius.x),
        radius: Radius.circular(rrect.trRadius.x),
      );
    }
    if (rrect.top + rrect.trRadius.x == rrect.bottom - rrect.brRadius.x) {
      arcTo(
        Rect.fromCircle(
          center: Offset(
            rrect.right - rrect.brRadius.x,
            rrect.bottom - rrect.brRadius.x,
          ),
          radius: rrect.brRadius.x,
        ),
        0,
        math.pi * 0.5,
        false,
      );
    } else {
      lineTo(rrect.right, rrect.bottom - rrect.brRadius.x);
      arcToPoint(
        Offset(rrect.right - rrect.brRadius.x, rrect.bottom),
        radius: Radius.circular(rrect.brRadius.x),
      );
    }
    if (rrect.right - rrect.brRadius.x == rrect.left + rrect.blRadius.x) {
      arcTo(
        Rect.fromCircle(
          center: Offset(
            rrect.left + rrect.blRadius.x,
            rrect.bottom - rrect.blRadius.x,
          ),
          radius: rrect.blRadius.x,
        ),
        math.pi * 0.5,
        math.pi * 0.5,
        false,
      );
    } else {
      lineTo(rrect.left + rrect.blRadius.x, rrect.bottom);
      arcToPoint(
        Offset(rrect.left, rrect.bottom - rrect.blRadius.x),
        radius: Radius.circular(rrect.blRadius.x),
      );
    }
    if (rrect.bottom - rrect.blRadius.x == rrect.top + rrect.tlRadius.x) {
      arcTo(
        Rect.fromCircle(
          center: Offset(
            rrect.left + rrect.tlRadius.x,
            rrect.top + rrect.tlRadius.x,
          ),
          radius: rrect.tlRadius.x,
        ),
        math.pi * 1.0,
        math.pi * 0.5,
        false,
      );
    } else {
      lineTo(rrect.left, rrect.top + rrect.tlRadius.x);
      arcToPoint(
        Offset(rrect.left + rrect.tlRadius.x, rrect.top),
        radius: Radius.circular(rrect.tlRadius.x),
      );
    }
    lineTo(rrect.right - rrect.trRadius.x, rrect.top);
  }

  void addPath(Path path, Offset offset, {Float64List? matrix4}) {
    if (path is MockPath) {
      _commands.addAll(path._commands);
    }
  }

  void extendWithPath(Path path, Offset offset, {Float64List? matrix4}) {}

  void close() {
    _commands.add({'action': 'close'});
  }

  void reset() {
    _commands.clear();
    _lastPoint = Offset(0, 0);
  }

  bool contains(Offset point) {
    return false;
  }

  Path shift(Offset offset) {
    return MockPath();
  }

  Path transform(Float64List matrix4) {
    return MockPath();
  }

  // see https://skia.org/user/api/SkPath_Reference#SkPath_getBounds
  Rect getBounds() {
    return Rect.zero;
  }

  static Path combine(PathOperation operation, Path path1, Path path2) {
    throw UnimplementedError();
  }

  PathMetrics computeMetrics({bool forceClosed = false}) {
    throw UnimplementedError();
  }
}
