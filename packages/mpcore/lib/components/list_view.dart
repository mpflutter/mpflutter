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
      attributes: {},
    );
  }
  final widget = element.widget as ListView;
  final isRoot = (() {
    if (widget.primary == false) {
      return false;
    } else if (widget.scrollDirection == Axis.vertical &&
        element.findAncestorWidgetOfExactType<Scrollable>() == null) {
      return true;
    } else {
      return false;
    }
  })();
  Element? appBarPinnedElement;
  if (isRoot && widget.scrollDirection == Axis.vertical) {
    final scaffoldState = element.findAncestorStateOfType<MPScaffoldState>();
    if (scaffoldState?.appBarKey.currentWidget is MPScaffoldAppBar &&
        (scaffoldState?.appBarKey.currentWidget as MPScaffoldAppBar).child
            is MPAppBarPinned) {
      appBarPinnedElement = scaffoldState!.appBarKey.currentContext as Element?;
    }
  }
  return MPElement(
    hashCode: element.hashCode,
    flutterElement: element,
    name: 'list_view',
    children: MPElement.childrenFromFlutterElement(
      indexedSemanticeParentElement,
    ),
    attributes: {
      'isRoot': isRoot,
      'appBarPinned': appBarPinnedElement != null
          ? MPElement.fromFlutterElement(appBarPinnedElement)
          : null,
      'padding': widget.padding?.toString(),
      'scrollDirection': widget.scrollDirection.toString(),
    },
  );
}
