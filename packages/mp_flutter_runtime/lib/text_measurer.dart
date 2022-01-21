part of './mp_flutter_runtime.dart';

class _TextMeasurer {
  MPEngine engine;

  _TextMeasurer({required this.engine});

  void _didReceivedDoMeasureData(Map data) {
    List items = data['items'];
    for (final item in items) {
      _measureText(item);
    }
    Future.delayed(const Duration(milliseconds: 1)).then((value) {
      engine._componentFactory._flushTextMeasureResult();
    });
  }

  void _measureText(Map item) {
    if (item['name'] == 'rich_text') {
      int hashCode = item['hashCode'];
      double maxWidth = 0.0;
      double maxHeight = 0.0;
      final textPainter = TextPainter();
      final textSpan = _RichText.spanFromData(item['children'], engine);
      textPainter.text = textSpan;
      textPainter.textDirection = TextDirection.ltr;
      Map? attributes = item['attributes'];
      if (attributes != null) {
        maxWidth = _Utils.toDouble(attributes['maxWidth'], 0.0);
        maxHeight = _Utils.toDouble(attributes['maxHeight'], 0.0);
        textPainter.maxLines = _Utils.toInt(attributes['maxLines'], 99999);
      }
      final dimensions = <PlaceholderDimensions>[];
      _addPlaceholderDimensions(textSpan, dimensions);
      textPainter.setPlaceholderDimensions(dimensions);
      textPainter.layout(maxWidth: maxWidth);
      Size measureResult = textPainter.size;
      engine._componentFactory._callbackTextMeasureResult(
        hashCode,
        measureResult,
      );
    }
  }

  void _addPlaceholderDimensions(
    InlineSpan span,
    List<PlaceholderDimensions> dimensions,
  ) {
    if (span is TextSpan && (span.children == null || span.children!.isEmpty)) {
      return;
    }
    span.visitChildren((childSpan) {
      if (childSpan is WidgetSpan) {
        final componentView = childSpan.child;
        if (componentView is ComponentView) {
          dimensions.add(
            PlaceholderDimensions(
              size: componentView.getSize(),
              alignment: PlaceholderAlignment.middle,
            ),
          );
        } else {
          dimensions.add(
            const PlaceholderDimensions(
              size: Size(0, 0),
              alignment: PlaceholderAlignment.middle,
            ),
          );
        }
      } else {
        _addPlaceholderDimensions(childSpan, dimensions);
      }
      return true;
    });
  }
}
