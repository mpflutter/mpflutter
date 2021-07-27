part of '../mpcore.dart';

MPElement _encodeVisibility(Element element) {
  final widget = element.widget as Visibility;
  return MPElement(
    hashCode: element.hashCode,
    flutterElement: element,
    name: 'visibility',
    children: MPElement.childrenFromFlutterElement(element),
    // ignore: invalid_use_of_protected_member
    constraints: element.findRenderObject()?.constraints,
    attributes: {
      'visible': widget.visible,
    },
  );
}

MPElement _encodeSliverVisibility(Element element) {
  final widget = element.widget as SliverVisibility;
  return MPElement(
    hashCode: element.hashCode,
    flutterElement: element,
    name: 'visibility',
    children: MPElement.childrenFromFlutterElement(element),
    // ignore: invalid_use_of_protected_member
    constraints: element.findRenderObject()?.constraints,
    attributes: {
      'visible': widget.visible,
    },
  );
}
