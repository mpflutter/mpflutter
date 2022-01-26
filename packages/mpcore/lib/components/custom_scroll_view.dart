part of '../mpcore.dart';

MPElement _encodeCustomScrollView(Element element) {
  final viewportElement = MPCore.findTarget<Viewport>(
    element,
    maxDepth: 20,
    singleChildOnly: true,
  );
  if (viewportElement == null) {
    return MPElement(
      hashCode: element.hashCode,
      flutterElement: element,
      name: 'custom_scroll_view',
      children: [],
      attributes: {},
    );
  }
  return MPElement(
    hashCode: element.hashCode,
    flutterElement: element,
    name: 'custom_scroll_view',
    children: MPElement.childrenFromFlutterElement(viewportElement),
    attributes: {
      ..._encodeScroller(element),
    },
  );
}
