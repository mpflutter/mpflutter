part of '../mpcore.dart';

MPElement _encodeAbsorbPointer(Element element) {
  final widget = element.widget as AbsorbPointer;
  return MPElement(
    hashCode: element.hashCode,
    flutterElement: element,
    name: 'absorb_pointer',
    children: MPElement.childrenFromFlutterElement(element),
    // ignore: invalid_use_of_protected_member
    constraints: element.findRenderObject()?.constraints,
    attributes: {'absorbing': widget.absorbing},
  );
}
