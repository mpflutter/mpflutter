part of 'mpkit.dart';

class MPTextPainter extends TextPainter {
  static final _measuringPainters = <String, Completer>{};

  static void onTextPainterMeasuredText(Map value) {
    String seqId = value['seqId'];
    Map size = value['size'];
    _measuringPainters[seqId]?.complete(
      Size(
        (size['width'] as num).toDouble(),
        (size['height'] as num).toDouble(),
      ),
    );
    _measuringPainters.remove(seqId);
  }

  static MPElement encodeSpan(InlineSpan span, int level, int index) {
    if (span is TextSpan) {
      final children = span.children != null
          ? span.children!
              .asMap()
              .map(((key, value) =>
                  MapEntry(key, encodeSpan(value, level + 1, key))))
              .values
              .toList()
          : null;
      if (children != null && span.text != null) {
        children.insert(
            0, encodeSpan(TextSpan(text: span.text), level + 1, -1));
      }
      return MPElement(
        hashCode: hashValues(span.hashCode, level, index),
        name: 'text_span',
        children: children,
        attributes: {
          'text': children == null ? span.text : null,
          'style': span.style != null ? encodeTextStyle(span.style!) : null,
        },
      );
    } else {
      return MPElement(
        hashCode: hashValues(span.hashCode, level, index),
        name: 'inline_span',
        attributes: {},
      );
    }
  }

  static Map encodeTextStyle(TextStyle style) {
    final map = {};
    if (style.fontFamily != null) {
      map['fontFamily'] = style.fontFamily;
    }
    if (style.fontSize != null) {
      map['fontSize'] = style.fontSize;
    }
    if (style.color != null) {
      map['color'] = style.color!.value.toString();
    }
    if (style.fontWeight != null) {
      map['fontWeight'] = style.fontWeight.toString();
    }
    if (style.fontStyle != null) {
      map['fontStyle'] = style.fontStyle.toString();
    }
    if (style.letterSpacing != null) {
      map['letterSpacing'] = style.letterSpacing;
    }
    if (style.wordSpacing != null) {
      map['wordSpacing'] = style.wordSpacing;
    }
    if (style.textBaseline != null) {
      map['textBaseline'] = style.textBaseline.toString();
    }
    if (style.height != null) {
      map['height'] = style.height;
    }
    if (style.backgroundColor != null) {
      map['backgroundColor'] = style.backgroundColor!.value.toString();
    }
    if (style.decoration != null) {
      if (style.decoration == TextDecoration.lineThrough) {
        map['decoration'] = 'TextDecoration.lineThrough';
      } else if (style.decoration == TextDecoration.underline) {
        map['decoration'] = 'TextDecoration.underline';
      }
    }
    return map;
  }

  Size? _measuredSize;

  @override
  Future layout({
    double minWidth = 0.0,
    double maxWidth = double.infinity,
  }) async {
    if (text == null) return;
    final seqId = '${hashCode}_${math.Random().nextDouble()}';
    final completer = Completer();
    MPChannel.postMessage(json.encode({
      'type': 'rich_text',
      'message': {
        'event': 'doMeasureTextPainter',
        'seqId': seqId,
        'minWidth': minWidth,
        'maxWidth': maxWidth,
        'text': encodeSpan(text!, 0, 0),
      }
    }));
    _measuringPainters[seqId] = completer;
    _measuredSize = await completer.future;
  }

  @override
  Size get size {
    return _measuredSize ?? Size(0, 0);
  }
}
