part of '../mpcore.dart';

MPElement _encodeSliverGrid(Element element) {
  final indexedSemanticeParentElement = MPCore.findTarget<KeyedSubtree>(
    element,
    findParent: true,
    maxDepth: 20,
    singleChildOnly: true,
  );
  if (indexedSemanticeParentElement == null) {
    return MPElement(
      hashCode: element.hashCode,
      flutterElement: element,
      name: 'sliver_grid',
      children: [],
      attributes: {},
    );
  }
  final widget = element.widget as SliverGrid;
  final padding =
      element.findAncestorWidgetOfExactType<SliverPadding>()?.padding;
  return MPElement(
    hashCode: element.hashCode,
    flutterElement: element,
    name: 'sliver_grid',
    children: MPElement.childrenFromFlutterElement(
      indexedSemanticeParentElement,
    ),
    attributes: {
      'padding': padding?.toString(),
      // ignore: invalid_use_of_protected_member
      'width': (element.findRenderObject()?.constraints as SliverConstraints)
          .crossAxisExtent,
      'gridDelegate': _encodeGridDelegate(widget.gridDelegate),
    },
  );
}
