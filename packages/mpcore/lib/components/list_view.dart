part of '../mpcore.dart';

MPElement _encodeListView(Element element) {
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
      name: 'list_view',
      children: [],
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
    attributes: {
      'padding': widget.padding?.toString(),
      ..._encodeScroller(element),
    },
  );
}
