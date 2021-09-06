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
      attributes: {},
    );
  }
  final widget = element.widget as CustomScrollView;
  final isRoot = (() {
    if ((element.widget as CustomScrollView).primary == false) {
      return false;
    } else if (element.findAncestorWidgetOfExactType<Scrollable>() == null) {
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
    name: 'custom_scroll_view',
    children: MPElement.childrenFromFlutterElement(viewportElement),
    attributes: {
      'isRoot': isRoot,
      'appBarPinned': appBarPinnedElement != null
          ? MPElement.fromFlutterElement(appBarPinnedElement)
          : null,
      'scrollDirection':
          (element.widget as CustomScrollView).scrollDirection.toString(),
    },
  );
}
