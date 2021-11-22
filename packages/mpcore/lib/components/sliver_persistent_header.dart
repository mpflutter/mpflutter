part of '../mpcore.dart';

MPElement _encodeSliverPersistentHeader(Element element) {
  final widget = element.widget as SliverPersistentHeader;
  final lazyWidget =
      element.findAncestorWidgetOfExactType<MPSliverPersistentHeader>();
  return MPElement(
    hashCode: element.hashCode,
    flutterElement: element,
    name: 'sliver_persistent_header',
    children: MPElement.childrenFromFlutterElement(element),
    attributes: {
      'pinned': widget.pinned,
      'lazying': lazyWidget?.lazying,
      'lazyOffset': lazyWidget?.lazyOffset,
    },
  );
}
