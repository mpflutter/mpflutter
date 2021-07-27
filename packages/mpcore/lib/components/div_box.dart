part of '../mpcore.dart';

MPElement _encodeDivBox(Element element) {
  final children = MPElement.childrenFromFlutterElement(element);
  if (children.length == 1) {
    return children[0];
  }
  return MPElement(
    hashCode: element.hashCode,
    flutterElement: element,
    name: 'div',
    children: children,
    attributes: {},
  );
}
