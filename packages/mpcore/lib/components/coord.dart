part of '../mpcore.dart';

const _coordIgnoringWidget = {
  IndexedSemantics: true,
  RepaintBoundary: true,
};

bool _isCoordElement(Element element) {
  if (_coordIgnoringWidget[element.widget.runtimeType] == true) {
    return false;
  } else if (element.widget is SingleChildRenderObjectWidget ||
      element.widget is MultiChildRenderObjectWidget) {
    return true;
  } else {
    return false;
  }
}

MPElement _encodeCoord(Element element) {
  final constraints = MPElement._getConstraints(element);
  var children = MPElement.childrenFromFlutterElement(element);
  if (constraints != null &&
      children.length == 1 &&
      children[0].constraints != null) {
    if (element.findRenderObject()?.parent is RenderRepaintBoundary) {
    } else if (element.findRenderObject()?.parent is RenderSliver) {
    } else if (constraints.left == 0 &&
        constraints.top == 0 &&
        constraints.size == children[0].constraints!.size) {
      return children[0];
    } else if (constraints.left == 0 &&
        constraints.top == 0 &&
        constraints.overlaps(children[0].constraints!)) {
      return children[0];
    }
    if (children[0].name == 'coord' &&
        children[0].children?.length == 1 &&
        children[0].constraints != null &&
        children[0].constraints!.left == 0 &&
        children[0].constraints!.top == 0 &&
        children[0].constraints!.size == constraints.size) {
      children = children[0].children!;
    }
  }
  return MPElement(
    hashCode: element.hashCode,
    flutterElement: element,
    name: 'coord',
    children: children,
  );
}
