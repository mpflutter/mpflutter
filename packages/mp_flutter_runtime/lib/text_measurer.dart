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
      textPainter.text = _RichText.spanFromData(item['children']);
      textPainter.textDirection = TextDirection.ltr;
      Map? attributes = item['attributes'];
      if (attributes != null) {
        maxWidth = double.tryParse(attributes['maxWidth'] ?? '0') ?? 0.0;
        maxHeight = double.tryParse(attributes['maxHeight'] ?? '0') ?? 0.0;
        textPainter.maxLines = attributes['maxLines'] ?? 99999;
      }
      textPainter.layout(maxWidth: maxWidth);
      Size measureResult = textPainter.size;
      engine._componentFactory._callbackTextMeasureResult(
        hashCode,
        measureResult,
      );
    }
  }
}
