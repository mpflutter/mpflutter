part of '../mpcore.dart';

MPElement _encodePositioned(Element element) {
  final widget = element.widget as Positioned;
  final attributes = {
    'left': widget.left,
    'top': widget.top,
    'right': widget.right,
    'bottom': widget.bottom,
    'width': widget.width,
    'height': widget.height,
  };
  if (widget.left == null &&
      widget.top == null &&
      widget.right == null &&
      widget.bottom == null &&
      widget.width == null &&
      widget.height == null) {
    attributes['left'] = 0;
    attributes['top'] = 0;
    attributes['right'] = 0;
    attributes['bottom'] = 0;
  }
  final children = MPElement.childrenFromFlutterElement(element);
  return MPElement(
    hashCode: element.hashCode,
    flutterElement: element,
    name: 'positioned',
    children: children,
    attributes: attributes,
  );
}
