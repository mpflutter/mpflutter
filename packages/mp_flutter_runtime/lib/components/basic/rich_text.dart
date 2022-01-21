part of '../../mp_flutter_runtime.dart';

class _RichText extends ComponentView {
  static InlineSpan spanFromData(List children, MPEngine engine) {
    final childrenSpan = <InlineSpan>[];
    for (final element in children) {
      if (element is Map) {
        String name = element['name'];
        if (name == 'text_span') {
          childrenSpan.add(textSpanFromData(element, engine));
        } else if (name == 'widget_span') {
          childrenSpan.add(widgetSpanFromData(element, engine));
        }
      }
    }
    final span = TextSpan(children: childrenSpan);
    return span;
  }

  static TextStyle textStyleFromData(Map? style) {
    Color spanTextColor = Colors.black;
    double spanTextSize = 14;
    String? spanFontFamily;
    FontWeight? spanFontWeight;
    FontStyle? spanFontStyle;
    double? spanLetterSpacing;
    double? spanWordSpacing;
    double? spanHeight;
    TextDecoration? spanTextDecoration;
    Color? spanBackgroundColor;
    if (style != null) {
      if (style['color'] is String) {
        spanTextColor = _Utils.toColor(style['color']);
      }
      if (style['fontSize'] is num) {
        spanTextSize = (style['fontSize'] as num).toDouble();
      }
      if (style['fontFamily'] is String) {
        spanFontFamily = style['fontFamily'];
      }
      if (style['fontWeight'] is String) {
        switch (style['fontWeight']) {
          case 'FontWeight.w100':
            spanFontWeight = FontWeight.w100;
            break;
          case 'FontWeight.w200':
            spanFontWeight = FontWeight.w200;
            break;
          case 'FontWeight.w300':
            spanFontWeight = FontWeight.w300;
            break;
          case 'FontWeight.w400':
            spanFontWeight = FontWeight.w400;
            break;
          case 'FontWeight.w500':
            spanFontWeight = FontWeight.w500;
            break;
          case 'FontWeight.w600':
            spanFontWeight = FontWeight.w600;
            break;
          case 'FontWeight.w700':
            spanFontWeight = FontWeight.w700;
            break;
          case 'FontWeight.w800':
            spanFontWeight = FontWeight.w800;
            break;
          case 'FontWeight.w900':
            spanFontWeight = FontWeight.w900;
            break;
          default:
        }
      }
      if (style['fontStyle'] is String) {
        switch (style['fontStyle']) {
          case 'FontStyle.italic':
            spanFontStyle = FontStyle.italic;
            break;
          default:
        }
      }
      if (style['letterSpacing'] is num) {
        spanLetterSpacing = (style['letterSpacing'] as num).toDouble();
      }
      if (style['wordSpacing'] is num) {
        spanWordSpacing = (style['wordSpacing'] as num).toDouble();
      }
      if (style['height'] is num) {
        spanHeight = (style['height'] as num).toDouble();
      }
      if (style['decoration'] is String) {
        switch (style['decoration']) {
          case 'TextDecoration.lineThrough':
            spanTextDecoration = TextDecoration.lineThrough;
            break;
          case 'TextDecoration.underline':
            spanTextDecoration = TextDecoration.underline;
            break;
          default:
        }
      }
      if (style['backgroundColor'] is String) {
        spanBackgroundColor = _Utils.toColor(style['backgroundColor']);
      }
    }
    return TextStyle(
      color: spanTextColor,
      fontSize: spanTextSize,
      fontFamily: spanFontFamily,
      fontWeight: spanFontWeight,
      fontStyle: spanFontStyle,
      letterSpacing: spanLetterSpacing,
      wordSpacing: spanWordSpacing,
      height: spanHeight,
      decoration: spanTextDecoration,
      backgroundColor: spanBackgroundColor,
    );
  }

  static InlineSpan textSpanFromData(Map child, MPEngine engine) {
    final children = child['children'];
    final attributes = child['attributes'];
    if (children == null && attributes is Map) {
      String? spanText = attributes['text'];
      final spanTextStyle = textStyleFromData(attributes['style']);
      final onTapEl = attributes['onTap_el'];
      final onTapSpan = attributes['onTap_span'];
      final span = TextSpan(
        text: spanText,
        style: spanTextStyle,
        recognizer: (() {
          if (onTapEl != null && onTapSpan != null) {
            return TapGestureRecognizer()
              ..onTap = () {
                engine._sendMessage({
                  "type": "rich_text",
                  "message": {
                    "event": "onTap",
                    "target": onTapEl,
                    "subTarget": onTapSpan,
                  }
                });
              };
          }
        })(),
      );
      return span;
    } else if (children != null) {
      return spanFromData(children, engine);
    }
    return const TextSpan(text: '');
  }

  static InlineSpan widgetSpanFromData(Map child, MPEngine engine) {
    List? children = child['children'];
    if (children == null || children.isEmpty) {
      return const WidgetSpan(child: SizedBox());
    }
    final childWidget = engine._componentFactory.create(children[0]);
    return WidgetSpan(
      child: childWidget,
    );
  }

  _RichText({
    Key? key,
    Map? data,
    Map? parentData,
    required _MPComponentFactory componentFactory,
  }) : super(
            key: key,
            data: data,
            parentData: parentData,
            componentFactory: componentFactory);

  TextAlign getTextAlign(BuildContext context) {
    String? value = getStringFromAttributes(context, 'textAlign');
    if (value == null) return TextAlign.left;
    switch (value) {
      case "TextAlign.left":
        return TextAlign.left;
      case "TextAlign.right":
        return TextAlign.right;
      case "TextAlign.center":
        return TextAlign.center;
      case "TextAlign.justify":
        return TextAlign.justify;
      case "TextAlign.start":
        return TextAlign.start;
      case "TextAlign.end":
        return TextAlign.end;
      default:
        return TextAlign.left;
    }
  }

  @override
  Widget builder(BuildContext context) {
    return RichText(
      text: spanFromData(ComponentViewState.getData(context)?['children'],
          componentFactory.engine),
      maxLines: getIntFromAttributes(context, 'maxLines') ?? 99999,
      overflow: TextOverflow.ellipsis,
      textAlign: getTextAlign(context),
    );
  }
}
