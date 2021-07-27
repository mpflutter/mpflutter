part of '../mpcore.dart';

MPElement _encodeListView(Element element) {
  final indexedSemanticeParentElement = MPCore.findTarget<KeyedSubtree>(
    element,
    findParent: true,
    maxDepth: 20,
  );
  if (indexedSemanticeParentElement == null) {
    return MPElement(
      hashCode: element.hashCode,
      flutterElement: element,
      name: 'list_view',
      children: [],
      // ignore: invalid_use_of_protected_member
      constraints: element.findRenderObject()?.constraints,
      attributes: {},
    );
  }
  final widget = element.widget as ListView;
  return MPElement(
    hashCode: element.hashCode,
    flutterElement: element,
    name: 'list_view',
    children: MPElement.childrenFromFlutterElement(
      indexedSemanticeParentElement,
    ),
    // ignore: invalid_use_of_protected_member
    constraints: element.findRenderObject()?.constraints,
    attributes: {
      'isRoot': (() {
        if (widget.primary == false) {
          return false;
        } else if (widget.scrollDirection == Axis.vertical &&
            element.findAncestorWidgetOfExactType<Scrollable>() == null) {
          return true;
        } else {
          return false;
        }
      })(),
      'padding': widget.padding?.toString(),
      'scrollDirection': widget.scrollDirection.toString(),
    },
  );
}
