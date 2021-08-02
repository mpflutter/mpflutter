part of '../mpcore.dart';

MPElement _encodeClipOval(Element element) {
  return MPElement(
    hashCode: element.hashCode,
    flutterElement: element,
    name: 'clip_oval',
    children: MPElement.childrenFromFlutterElement(element),
    attributes: {},
  );
}
