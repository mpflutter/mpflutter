part of '../mpcore.dart';

MPElement _encodeSingleChildScrollView(Element element) {
  final scrollable = MPCore.findTarget<Scrollable>(
    element,
    maxDepth: 20,
    singleChildOnly: true,
  );
  if (scrollable == null) {
    return MPElement(
      hashCode: element.hashCode,
      flutterElement: element,
      name: 'list_view',
      children: [],
      attributes: {},
    );
  }
  final widget = element.widget as SingleChildScrollView;
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
    name: 'list_view',
    children: MPElement.childrenFromFlutterElement(
      scrollable,
    ),
    attributes: {
      'isRoot': isRoot,
      'appBarPinned': appBarPinnedElement != null
          ? MPElement.fromFlutterElement(appBarPinnedElement)
          : null,
      'bottomBarHeight': bottomBarHeight,
      'bottomBarWithSafeArea': bottomBarWithSafeArea,
      'padding': widget.padding?.toString(),
      'scrollDirection': widget.scrollDirection.toString(),
      'restorationId': widget.restorationId,
      'onScroll': hasScrollNotificationListener ? element.hashCode : null,
    },
  );
}
