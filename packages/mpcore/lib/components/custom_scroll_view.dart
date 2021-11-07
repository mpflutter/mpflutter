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
  var bottomBarHeight = 0.0;
  var bottomBarWithSafeArea = false;
  if (isRoot && widget.scrollDirection == Axis.vertical) {
    final scaffoldState = element.findAncestorStateOfType<MPScaffoldState>();
    if (scaffoldState?.appBarKey.currentWidget != null) {
      appBarPinnedElement = MPCore.findTarget<MPAppBarPinned>(
        scaffoldState!.appBarKey.currentContext as Element?,
        findParent: true,
        maxDepth: 20,
        singleChildOnly: true,
      );
    }
    bottomBarHeight =
        scaffoldState?.bottomBarKey.currentContext?.size?.height ?? 0.0;
    bottomBarWithSafeArea =
        scaffoldState?.widget.bottomBarWithSafeArea ?? false;
  }
  final hasScrollNotificationListener = (() {
    var hasResult = false;
    element.visitAncestorElements((element) {
      if (element.widget is NotificationListener<ScrollNotification>) {
        hasResult = true;
      }
      return false;
    });
    return hasResult;
  })();
  if (hasScrollNotificationListener) {
    MPCore.addElementToHashCodeCache(element);
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
      'bottomBarHeight': bottomBarHeight,
      'bottomBarWithSafeArea': bottomBarWithSafeArea,
      'scrollDirection':
          (element.widget as CustomScrollView).scrollDirection.toString(),
      'restorationId': widget.restorationId,
      'onScroll': hasScrollNotificationListener ? element.hashCode : null,
    },
  );
}
