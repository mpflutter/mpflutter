part of '../mpcore.dart';

class MPDrawable implements ui.Image {
  static final Map<int, Completer> _decodeHandlers = {};
  static final Map<int, MPDrawable> _decodeDrawables = {};

  static Future<MPDrawable> fromNetworkImage(String url) async {
    final completer = Completer<MPDrawable>();
    final drawable = MPDrawable();
    _decodeHandlers[drawable.hashCode] = completer;
    _decodeDrawables[drawable.hashCode] = drawable;
    MPChannel.postMessage(
      json.encode({
        'type': 'decode_drawable',
        'flow': 'request',
        'message': {
          'type': 'networkImage',
          'url': url,
          'target': drawable.hashCode,
        },
      }),
      forLastConnection: true,
    );
    return completer.future;
  }

  static Future<MPDrawable> fromMemoryImage(
    Uint8List data, {
    String imageType = 'png',
  }) async {
    final completer = Completer<MPDrawable>();
    final drawable = MPDrawable();
    _decodeHandlers[drawable.hashCode] = completer;
    _decodeDrawables[drawable.hashCode] = drawable;
    MPChannel.postMessage(
      json.encode({
        'type': 'decode_drawable',
        'flow': 'request',
        'message': {
          'type': 'memoryImage',
          'data': base64.encode(data),
          'imageType': imageType,
          'target': drawable.hashCode,
        },
      }),
      forLastConnection: true,
    );
    return completer.future;
  }

  static Future<MPDrawable> fromAssetImage(
    String assetName, {
    String? assetPkg,
  }) async {
    final completer = Completer<MPDrawable>();
    final drawable = MPDrawable();
    _decodeHandlers[drawable.hashCode] = completer;
    _decodeDrawables[drawable.hashCode] = drawable;
    MPChannel.postMessage(
      json.encode({
        'type': 'decode_drawable',
        'flow': 'request',
        'message': {
          'type': 'assetImage',
          'assetName': assetName,
          'assetPkg': assetPkg,
          'target': drawable.hashCode,
        },
      }),
      forLastConnection: true,
    );
    return completer.future;
  }

  static void receivedDecodedResult(Map params) {
    int target = params['target'];
    final handler = _decodeHandlers[target];
    final drawable = _decodeDrawables[target];
    if (handler != null && drawable != null) {
      drawable._width = params['width'];
      drawable._height = params['height'];
      handler.complete(drawable);
    }
    _decodeHandlers.remove(target);
    _decodeDrawables.remove(target);
  }

  static void receivedDecodedError(Map params) {
    int target = params['target'];
    final handler = _decodeHandlers[target];
    final drawable = _decodeDrawables[target];
    if (handler != null && drawable != null) {
      handler.completeError(params['error']);
    }
    _decodeHandlers.remove(target);
    _decodeDrawables.remove(target);
  }

  MPDrawable();

  int _width = 0;

  int _height = 0;

  @override
  void dispose() {
    MPChannel.postMessage(
      json.encode({
        'type': 'decode_drawable',
        'flow': 'request',
        'message': {
          'type': 'dispose',
          'target': hashCode,
        },
      }),
      forLastConnection: true,
    );
  }

  @override
  int get height => _height;

  @override
  Future<ByteData?> toByteData(
      {ui.ImageByteFormat format = ui.ImageByteFormat.rawRgba}) async {
    return null;
  }

  @override
  int get width => _width;
}

class _RecordingCanvas implements Canvas {
  final List<Map> _commands = [];
  int _saveCount = 0;

  @override
  void clipPath(ui.Path path, {bool doAntiAlias = true}) {
    _commands.add({
      'action': 'clipPath',
      'path': path,
    });
  }

  @override
  void clipRRect(ui.RRect rrect, {bool doAntiAlias = true}) {
    final path = ui.Path();
    path.addRRect(rrect);
    clipPath(path);
  }

  @override
  void clipRect(
    ui.Rect rect, {
    ui.ClipOp clipOp = ui.ClipOp.intersect,
    bool doAntiAlias = true,
  }) {
    final path = ui.Path();
    path.addRect(rect);
    _commands.add({
      'action': 'clipPath',
      'path': path,
      'clipOp': clipOp.toString(),
    });
  }

  @override
  void drawArc(ui.Rect rect, double startAngle, double sweepAngle,
      bool useCenter, ui.Paint paint) {
    final path = ui.Path();
    if (useCenter == true) {
      path.moveTo(rect.center.dx, rect.center.dy);
    }
    path.addArc(rect, startAngle, sweepAngle);
    drawPath(path, paint);
  }

  @override
  void drawAtlas(
      ui.Image atlas,
      List<ui.RSTransform> transforms,
      List<ui.Rect> rects,
      List<ui.Color>? colors,
      ui.BlendMode? blendMode,
      ui.Rect? cullRect,
      ui.Paint paint) {}

  @override
  void drawCircle(Offset c, double radius, ui.Paint paint) {
    final path = ui.Path();
    path.addOval(Rect.fromCircle(center: c, radius: radius));
    drawPath(path, paint);
  }

  @override
  void drawColor(ui.Color color, ui.BlendMode blendMode) {
    _commands.add({
      'action': 'drawColor',
      'color': color.value.toString(),
      'blendMode': blendMode.toString(),
    });
  }

  @override
  void drawDRRect(ui.RRect outer, ui.RRect inner, ui.Paint paint) {
    final outerPath = ui.MockPath()..addRRect(outer);
    final innerPath = ui.MockPath()..addRRect(inner);

    _commands.add({
      'action': 'drawDRRect',
      'outer': outerPath.toJson(),
      'inner': innerPath.toJson(),
      'paint': encodePaint(paint),
    });
  }

  @override
  void drawImage(ui.Image image, Offset offset, ui.Paint paint) {
    if (image is MPDrawable) {
      _commands.add({
        'action': 'drawImage',
        'drawable': image.hashCode,
        'dx': offset.dx,
        'dy': offset.dy,
        'paint': encodePaint(paint, encodeAlpha: true),
      });
    }
  }

  @override
  void drawImageNine(
      ui.Image image, ui.Rect center, ui.Rect dst, ui.Paint paint) {
    throw 'Not support.';
  }

  @override
  void drawImageRect(ui.Image image, ui.Rect src, ui.Rect dst, ui.Paint paint) {
    if (image is MPDrawable) {
      _commands.add({
        'action': 'drawImageRect',
        'drawable': image.hashCode,
        'srcX': src.left,
        'srcY': src.top,
        'srcW': src.width,
        'srcH': src.height,
        'dstX': dst.left,
        'dstY': dst.top,
        'dstW': dst.width,
        'dstH': dst.height,
        'paint': encodePaint(paint, encodeAlpha: true),
      });
    }
  }

  @override
  void drawLine(Offset p1, Offset p2, ui.Paint paint) {
    final path = ui.Path();
    path.moveTo(p1.dx, p1.dy);
    path.lineTo(p2.dx, p2.dy);
    drawPath(path, paint);
  }

  @override
  void drawOval(ui.Rect rect, ui.Paint paint) {
    final path = ui.Path();
    path.addOval(rect);
    drawPath(path, paint);
  }

  @override
  void drawPaint(ui.Paint paint) {
    drawColor(paint.color, paint.blendMode);
  }

  @override
  void drawParagraph(ui.Paragraph paragraph, Offset offset) {}

  @override
  void drawText(String text, dynamic style, Offset offset, ui.Paint paint) {
    if (style is TextStyle) {
      _commands.add(
        {
          'action': 'drawText',
          'text': text,
          'style': MPTextPainter.encodeTextStyle(style),
          'offset': {
            'x': offset.dx,
            'y': offset.dy,
          },
          'paint': encodePaint(paint),
        },
      );
    }
  }

  @override
  void drawPath(ui.Path path, ui.Paint paint) {
    _commands.add({
      'action': 'drawPath',
      'path': (path as ui.MockPath).toJson(),
      'paint': encodePaint(paint),
    });
  }

  @override
  void drawPicture(ui.Picture picture) {}

  @override
  void drawPoints(
      ui.PointMode pointMode, List<Offset> points, ui.Paint paint) {}

  @override
  void drawRRect(ui.RRect rrect, ui.Paint paint) {
    final path = ui.Path();
    if (min(rrect.width, rrect.height) / 2.0 == rrect.blRadiusX ||
        min(rrect.width, rrect.height) / 2.0 == rrect.blRadiusY) {
      path.addRRect(
        ui.RRect.fromRectAndRadius(
          rrect.outerRect,
          Radius.circular(rrect.blRadiusX - 0.1),
        ),
      );
      drawPath(path, paint);
    } else {
      path.addRRect(rrect);
      drawPath(path, paint);
    }
  }

  @override
  void drawRawAtlas(
      ui.Image atlas,
      Float32List rstTransforms,
      Float32List rects,
      Int32List? colors,
      ui.BlendMode? blendMode,
      ui.Rect? cullRect,
      ui.Paint paint) {}

  @override
  void drawRawPoints(
      ui.PointMode pointMode, Float32List points, ui.Paint paint) {}

  @override
  void drawRect(ui.Rect rect, ui.Paint paint) {
    _commands.add({
      'action': 'drawRect',
      'x': rect.left,
      'y': rect.top,
      'width': rect.width,
      'height': rect.height,
      'paint': encodePaint(paint),
    });
  }

  @override
  void drawShadow(ui.Path path, ui.Color color, double elevation,
      bool transparentOccluder) {}

  @override
  void drawVertices(
      ui.Vertices vertices, ui.BlendMode blendMode, ui.Paint paint) {}

  @override
  int getSaveCount() {
    return _saveCount;
  }

  @override
  void restore() {
    _saveCount--;
    _commands.add({'action': 'restore'});
  }

  @override
  void rotate(double radians) {
    _commands.add({'action': 'rotate', 'radians': radians});
  }

  @override
  void save() {
    _saveCount++;
    _commands.add({'action': 'save'});
  }

  @override
  void saveLayer(ui.Rect? bounds, ui.Paint paint) {}

  @override
  void scale(double sx, [double? sy]) {
    _commands.add({'action': 'scale', 'sx': sx, 'sy': sy ?? sx});
  }

  @override
  void skew(double sx, double sy) {
    _commands.add({'action': 'skew', 'sx': sx, 'sy': sy});
  }

  @override
  void transform(Float64List matrix4) {
    _commands.add({
      'action': 'transform',
      'a': matrix4[0],
      'b': matrix4[1],
      'c': matrix4[4],
      'd': matrix4[5],
      'tx': matrix4[12],
      'ty': matrix4[13],
    });
  }

  @override
  void translate(double dx, double dy) {
    _commands.add({'action': 'translate', 'dx': dx, 'dy': dy});
  }

  Map encodePaint(ui.Paint paint, {bool encodeAlpha = false}) {
    final result = {
      'blendMode': paint.blendMode.toString(),
      'style': paint.style.toString(),
      'strokeWidth': paint.strokeWidth,
      'strokeCap': paint.strokeCap.toString(),
      'strokeJoin': paint.strokeJoin.toString(),
      'color': paint.color.value.toString(),
      'gradient': (() {
        final shader = paint.shader;
        if (shader != null) {
          if (shader is ui.MockGradientLinear) {
            return {
              'classname': 'LinearGradient',
              'fromX': shader.from.dx,
              'fromY': shader.from.dy,
              'toX': shader.to.dx,
              'toY': shader.to.dy,
              'colors': shader.colors.map((e) => e.value.toString()).toList(),
              'stops': shader.colorStops,
            };
          } else if (shader is ui.MockGradientRadial) {
            final radialGradient = shader.originGradient as RadialGradient;
            return {
              'classname': 'RadialGradient',
              'center': radialGradient.center.toString(),
              'radius': radialGradient.radius.toString(),
              'colors':
                  radialGradient.colors.map((e) => e.value.toString()).toList(),
              'stops': radialGradient.stops,
              'tileMode': radialGradient.tileMode.toString(),
            };
          }
        }
      })(),
      'strokeMiterLimit': paint.strokeMiterLimit,
    };
    if (encodeAlpha && paint.color.value > 0) {
      result['alpha'] = paint.color.opacity;
    }
    return result;
  }
}

final Map<int, dynamic> _lastAsyncPaintCommands = {};

MPElement _encodeCustomPaint(Element element) {
  final widget = element.widget as CustomPaint;
  final recordingCanvas = _RecordingCanvas();
  recordingCanvas.drawColor(Colors.transparent, ui.BlendMode.clear);
  final painter = widget.painter;
  if (painter != null) {
    if (painter.isAsyncPainter()) {
      painter.asyncPaintSequenceId++;
      final currentSeqId = painter.asyncPaintSequenceId;
      painter.paintAsync(recordingCanvas, widget.size).then((_) {
        if (currentSeqId != painter.asyncPaintSequenceId) return;
        if ((element.widget as CustomPaint).painter != painter) return;
        _lastAsyncPaintCommands[element.hashCode] = recordingCanvas._commands;
        MPChannel.postMessage(
          json.encode({
            'type': 'custom_paint',
            'flow': 'request',
            'message': {
              'event': 'asyncPaint',
              'target': element.hashCode,
              'width': widget.size.width,
              'height': widget.size.height,
              'commands': recordingCanvas._commands,
            },
          }),
          forLastConnection: true,
        );
      });
    } else {
      painter.paint(recordingCanvas, widget.size);
    }
  }
  return MPElement(
    hashCode: element.hashCode,
    flutterElement: element,
    name: 'custom_paint',
    children: MPElement.childrenFromFlutterElement(element),
    attributes: {
      'width': widget.size.width,
      'height': widget.size.height,
      'commands': _lastAsyncPaintCommands[element.hashCode] ??
          recordingCanvas._commands,
    },
  );
}
