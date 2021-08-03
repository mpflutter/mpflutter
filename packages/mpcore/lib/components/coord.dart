part of '../mpcore.dart';

bool _isCoordElement(Element element) {
  if (element.widget is SingleChildRenderObjectWidget ||
      element.widget is MultiChildRenderObjectWidget) {
    return true;
  } else {
    return false;
  }
}

MPElement _encodeCoord(Element element) {
  return MPElement(
    hashCode: element.hashCode,
    flutterElement: element,
    name: 'coord',
    children: MPElement.childrenFromFlutterElement(element),
  );
}
