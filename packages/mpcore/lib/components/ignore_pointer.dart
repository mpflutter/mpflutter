part of '../mpcore.dart';

MPElement _encodeIgnorePointer(Element element) {
  final widget = element.widget as IgnorePointer;
  return MPElement(
    hashCode: element.hashCode,
    flutterElement: element,
    name: 'ignore_pointer',
    children: MPElement.childrenFromFlutterElement(element),
    // ignore: invalid_use_of_protected_member
    constraints: element.findRenderObject()?.constraints,
    attributes: {'ignoring': widget.ignoring},
  );
}
