part of '../mpcore.dart';

Map _encodeScroller(Element element) {
  final widget = element.widget as ScrollView;
  final isRoot = (() {
    if (element.size != MediaQuery.of(element).size) {
      return false;
    } else if (widget.primary == false) {
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
    if (!hasResult) {
      if (isRoot) {
        return element
                .findAncestorWidgetOfExactType<MPScaffold>()
                ?.onPageScroll !=
            null;
      }
    }
    return hasResult;
  })();
  if (hasScrollNotificationListener) {
    MPCore.addElementToHashCodeCache(element);
  }
  final refreshIndicator =
      element.findAncestorWidgetOfExactType<MPRefreshIndicator>();
  var hasRefreshIndicator = refreshIndicator != null &&
      refreshIndicator.enableChecker?.call(element.widget.key) != false;
  if (!hasRefreshIndicator && isRoot) {
    if (element.findAncestorWidgetOfExactType<MPScaffold>()?.onRefresh !=
        null) {
      hasRefreshIndicator = true;
    }
  }
  if (hasRefreshIndicator) {
    MPCore.addElementToHashCodeCache(element);
  }
  return {
    'scrollDirection': widget.scrollDirection.toString(),
    'isRoot': isRoot,
    'appBarPinned': appBarPinnedElement != null
        ? MPElement.fromFlutterElement(appBarPinnedElement)
        : null,
    'bottomBarHeight': bottomBarHeight,
    'bottomBarWithSafeArea': bottomBarWithSafeArea,
    'restorationId': widget.restorationId,
    'onScroll': hasScrollNotificationListener ? element.hashCode : null,
    'onRefresh': hasRefreshIndicator ? element.hashCode : null,
  };
}
