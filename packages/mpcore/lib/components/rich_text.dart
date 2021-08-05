part of '../mpcore.dart';

Map<int, Element> _measuringText = {};

void _onMeasuredText(List values) {
  values.forEach((element) {
    if (element is Map) {
      final measureId = element['measureId'];
      final size = Size(
        (element['size']['width'] as num).toDouble(),
        (element['size']['height'] as num).toDouble(),
      );
      final fltElement = _measuringText[measureId];
      if (fltElement == null) {
        return;
      }
      _measuringText.remove(measureId);
      final renderObject = fltElement.findRenderObject();
      if (!(renderObject is RenderParagraph)) {
        return;
      }
      renderObject.measuredSize = size;
      renderObject.reassemble();
    }
  });
  _measuringText.forEach((key, fltElement) {
    final renderObject = fltElement.findRenderObject();
    if (!(renderObject is RenderParagraph)) {
      return;
    }
    renderObject.measuredSize = Size(0, 0);
    renderObject.reassemble();
  });
  _measuringText.clear();
  WidgetsBinding.instance?.scheduleFrame();
}

MPElement _encodeRichText(Element element) {
  final widget = element.widget as RichText;
  final renderObject = element.findRenderObject();
  // ignore: invalid_use_of_protected_member
  var constraints = element.findRenderObject()?.constraints as BoxConstraints?;
  if (renderObject is RenderParagraph &&
      renderObject.hasSize &&
      renderObject.measuredSize != null) {
    if (renderObject.size.width + 1.0 < renderObject.measuredSize!.width ||
        renderObject.size.height + 1.0 < renderObject.measuredSize!.height) {
      renderObject.measuredSize = null;
    } else {
      constraints = BoxConstraints(
        minWidth: renderObject.size.width,
        minHeight: renderObject.size.height,
        maxWidth: renderObject.size.width,
        maxHeight: renderObject.size.height,
      );
    }
  }
  if (renderObject is RenderParagraph && renderObject.measuredSize == null) {
    _measuringText[element.hashCode] = element;
  }
  constraints ??= BoxConstraints(
    minWidth: 0,
    minHeight: 0,
    maxWidth: double.infinity,
    maxHeight: double.infinity,
  );
  return MPElement(
    hashCode: element.hashCode,
    flutterElement: element,
    name: 'rich_text',
    children: [_encodeSpan(widget.text, element, 0, 0)],
    attributes: {
      'measureId':
          renderObject is RenderParagraph && renderObject.measuredSize == null
              ? element.hashCode
              : null,
      'maxWidth': constraints.maxWidth.toString(),
      'maxHeight': constraints.maxHeight.toString(),
      'maxLines': widget.maxLines,
      'textAlign': widget.textAlign.toString(),
    },
  );
}

MPElement _encodeSpan(
    InlineSpan span, Element richTextElement, int level, int index) {
  if (span is TextSpan) {
    final children = span.children != null
        ? span.children!
            .asMap()
            .map(((key, value) => MapEntry(
                key, _encodeSpan(value, richTextElement, level + 1, key))))
            .values
            .toList()
        : null;
    if (children != null && span.text != null) {
      children.insert(
          0,
          _encodeSpan(
              TextSpan(text: span.text), richTextElement, level + 1, -1));
    }
    return MPElement(
      hashCode:
          ui.hashValues(span.hashCode, richTextElement.hashCode, level, index),
      name: 'text_span',
      children: children,
      attributes: {
        'text': children == null ? span.text : null,
        'style': span.style != null ? _encodeTextStyle(span.style!) : null,
        'onTap_el': (() {
          if (span.recognizer is TapGestureRecognizer) {
            return richTextElement.hashCode;
          }
        })(),
        'onTap_span': (() {
          if (span.recognizer is TapGestureRecognizer) {
            return span.hashCode;
          }
        })(),
      },
    );
  } else if (span is WidgetSpan) {
    final targetElement = MPCore.findTargetHashCode(span.child.hashCode,
        element: richTextElement);
    if (targetElement == null) {
      return MPElement(
        hashCode: ui.hashValues(
            span.hashCode, richTextElement.hashCode, level, index),
        name: 'inline_span',
        attributes: {},
      );
    }
    return MPElement(
      hashCode:
          ui.hashValues(span.hashCode, richTextElement.hashCode, level, index),
      name: 'widget_span',
      children: [MPElement.fromFlutterElement(targetElement)],
      attributes: {},
    );
  } else {
    return MPElement(
      hashCode:
          ui.hashValues(span.hashCode, richTextElement.hashCode, level, index),
      name: 'inline_span',
      attributes: {},
    );
  }
}

Map _encodeTextStyle(TextStyle style) {
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
