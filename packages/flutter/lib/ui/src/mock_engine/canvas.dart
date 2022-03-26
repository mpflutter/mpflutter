part of dart.ui;

class MockCanvas implements Canvas {
  void save() {}
  void saveLayer(Rect? bounds, Paint paint) {}
  void restore() {}
  int getSaveCount() {
    return 0;
  }

  void translate(double dx, double dy) {}
  void scale(double sx, [double? sy]) {}
  void rotate(double radians) {}
  void skew(double sx, double sy) {}
  void transform(Float64List matrix4) {}
  void clipRect(Rect rect,
      {ClipOp clipOp = ClipOp.intersect, bool doAntiAlias = true}) {}
  void clipRRect(RRect rrect, {bool doAntiAlias = true}) {}
  void clipPath(Path path, {bool doAntiAlias = true}) {}
  void drawColor(Color color, BlendMode blendMode) {}
  void drawLine(Offset p1, Offset p2, Paint paint) {}
  void drawPaint(Paint paint) {}
  void drawRect(Rect rect, Paint paint) {}
  void drawRRect(RRect rrect, Paint paint) {}
  void drawDRRect(RRect outer, RRect inner, Paint paint) {}
  void drawOval(Rect rect, Paint paint) {}
  void drawCircle(Offset c, double radius, Paint paint) {}
  void drawArc(Rect rect, double startAngle, double sweepAngle, bool useCenter,
      Paint paint) {}
  void drawPath(Path path, Paint paint) {}
  void drawImage(Image image, Offset offset, Paint paint) {}
  void drawImageRect(Image image, Rect src, Rect dst, Paint paint) {}
  void drawImageNine(Image image, Rect center, Rect dst, Paint paint) {}
  void drawPicture(Picture picture) {}
  void drawParagraph(Paragraph paragraph, Offset offset) {}
  void drawText(String text, dynamic style, Offset offset, Paint paint) {}
  void drawPoints(PointMode pointMode, List<Offset> points, Paint paint) {}
  void drawRawPoints(PointMode pointMode, Float32List points, Paint paint) {}

  void drawVertices(Vertices vertices, BlendMode blendMode, Paint paint) {}
  void drawAtlas(
    Image atlas,
    List<RSTransform> transforms,
    List<Rect> rects,
    List<Color>? colors,
    BlendMode? blendMode,
    Rect? cullRect,
    Paint paint,
  ) {}
  void drawRawAtlas(
    Image atlas,
    Float32List rstTransforms,
    Float32List rects,
    Int32List? colors,
    BlendMode? blendMode,
    Rect? cullRect,
    Paint paint,
  ) {}
  void drawShadow(
    Path path,
    Color color,
    double elevation,
    bool transparentOccluder,
  ) {}
}

class MockPictureRecorder implements PictureRecorder {
  bool get isRecording => false;

  Picture endRecording() {
    return MockPicture();
  }
}

class MockPicture implements Picture {
  Future<Image> toImage(int width, int height) async {
    return MockImage();
  }

  void dispose() {}

  int get approximateBytesUsed => 0;
}

class MockImage implements Image {
  int get width => 0;
  int get height => 0;
  Future<ByteData?> toByteData(
      {ImageByteFormat format = ImageByteFormat.rawRgba}) async {
    return null;
  }

  void dispose() {}
}
