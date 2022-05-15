part of '../mpcore.dart';

MPElement _encodeMouseRegion(Element element) {
  MPCore.addElementToHashCodeCache(element);
  final widget = element.widget as MouseRegion;
  return MPElement(
    hashCode: element.hashCode,
    flutterElement: element,
    name: 'mouse_region',
    children: MPElement.childrenFromFlutterElement(element),
    attributes: {
      'cursor': widget.cursor.toString(),
    },
  );
}
