part of '../mpcore.dart';

MPElement _encodeCoord(Element element) {
  return MPElement(
    hashCode: element.hashCode,
    flutterElement: element,
    name: 'coord',
    children: MPElement.childrenFromFlutterElement(element),
    attributes: {},
  );
}
