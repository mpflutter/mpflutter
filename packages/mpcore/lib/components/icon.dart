part of '../mpcore.dart';

MPElement _encodeIcon(Element element) {
  final widget = element.widget as Icon;
  return MPElement(
    hashCode: element.hashCode,
    flutterElement: element,
    name: 'icon',
    // ignore: invalid_use_of_protected_member
    constraints: element.findRenderObject()?.constraints,
    attributes: {
      'icon': {
        'fontFamily': widget.icon?.fontFamily,
        'codePoint': widget.icon?.codePoint,
      },
      'color': widget.color != null ? widget.color?.value.toString() : null,
      'size': widget.size,
    },
  );
}
