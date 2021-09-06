part of '../mpcore.dart';

MPElement _encodeSliverList(Element element) {
  final indexedSemanticeParentElement = MPCore.findTarget<KeyedSubtree>(
    element,
    findParent: true,
    maxDepth: 20,
    singleChildOnly: true,
  );
  if (indexedSemanticeParentElement == null) {
    return MPElement(
      hashCode: element.hashCode,
      name: 'sliver_list',
      children: [],
      attributes: {},
    );
  }
  final padding =
      element.findAncestorWidgetOfExactType<SliverPadding>()?.padding;
  return MPElement(
    hashCode: element.hashCode,
    flutterElement: element,
    name: 'sliver_list',
    children: MPElement.childrenFromFlutterElement(
      indexedSemanticeParentElement,
    ),
    attributes: {
      'padding': padding?.toString(),
    },
  );
}
