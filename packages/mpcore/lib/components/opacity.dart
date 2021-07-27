part of '../mpcore.dart';

MPElement _encodeOpacity(Element element) {
  final widget = element.widget as Opacity;
  return MPElement(
    hashCode: element.hashCode,
    flutterElement: element,
    name: 'opacity',
    children: MPElement.childrenFromFlutterElement(element),
    // ignore: invalid_use_of_protected_member
    constraints: element.findRenderObject()?.constraints,
    attributes: {
      'opacity': widget.opacity,
    },
  );
}

MPElement _encodeSliverOpacity(Element element) {
  final widget = element.widget as SliverOpacity;
  return MPElement(
    hashCode: element.hashCode,
    flutterElement: element,
    name: 'opacity',
    children: MPElement.childrenFromFlutterElement(element),
    // ignore: invalid_use_of_protected_member
    constraints: element.findRenderObject()?.constraints,
    attributes: {
      'opacity': widget.opacity,
    },
  );
}
