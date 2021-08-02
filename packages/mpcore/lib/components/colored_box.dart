part of '../mpcore.dart';

MPElement _encodeColoredBox(Element element) {
  final widget = element.widget as ColoredBox;
  return MPElement(
    hashCode: element.hashCode,
    flutterElement: element,
    name: 'colored_box',
    children: MPElement.childrenFromFlutterElement(element),
    attributes: {'color': widget.color.value.toString()},
  );
}
