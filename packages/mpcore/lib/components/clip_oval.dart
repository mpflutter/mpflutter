part of '../mpcore.dart';

MPElement _encodeClipOval(Element element) {
  return MPElement(
    hashCode: element.hashCode,
    flutterElement: element,
    name: 'clip_oval',
    children: MPElement.childrenFromFlutterElement(element),
    // ignore: invalid_use_of_protected_member
    constraints: element.findRenderObject()?.constraints,
    attributes: {},
  );
}
