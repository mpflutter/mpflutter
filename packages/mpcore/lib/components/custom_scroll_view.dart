part of '../mpcore.dart';

MPElement _encodeCustomScrollView(Element element) {
  final viewportElement = MPCore.findTarget<Viewport>(
    element,
    maxDepth: 20,
  );
  if (viewportElement == null) {
    return MPElement(
      hashCode: element.hashCode,
      flutterElement: element,
      name: 'custom_scroll_view',
      children: [],
      // ignore: invalid_use_of_protected_member
      constraints: element.findRenderObject()?.constraints,
      attributes: {},
    );
  }
  return MPElement(
    hashCode: element.hashCode,
    flutterElement: element,
    name: 'custom_scroll_view',
    children: MPElement.childrenFromFlutterElement(viewportElement),
    // ignore: invalid_use_of_protected_member
    constraints: element.findRenderObject()?.constraints,
    attributes: {
      'isRoot': (() {
        if ((element.widget as CustomScrollView).primary == false) {
          return false;
        } else if (element.findAncestorWidgetOfExactType<Scrollable>() ==
                null &&
            element.findAncestorWidgetOfExactType<Align>() == null &&
            element.findAncestorWidgetOfExactType<Center>() == null) {
          return true;
        } else {
          return false;
        }
      })(),
      'scrollDirection':
          (element.widget as CustomScrollView).scrollDirection.toString(),
    },
  );
}
