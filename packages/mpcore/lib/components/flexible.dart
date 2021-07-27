part of '../mpcore.dart';

MPElement _encodeFlexible(Element element) {
  final widget = element.widget as Flexible;
  return MPElement(
    hashCode: element.hashCode,
    flutterElement: element,
    name: 'flexible',
    children: MPElement.childrenFromFlutterElement(element),
    // ignore: invalid_use_of_protected_member
    constraints: element.findRenderObject()?.constraints,
    attributes: {
      'flex': widget.flex,
      'fit': widget.fit.toString(),
    },
  );
}
