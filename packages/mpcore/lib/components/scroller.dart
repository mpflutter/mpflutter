part of '../mpcore.dart';

Map _encodeScroller(Element element) {
  final widget = element.widget as ScrollView;
  if (widget.controller != null) {
    widget.controller?.eventEmitter = (event, eventParams) {
      MPChannel.postMessage(
        json.encode({
          'type': 'scroll_view',
          'message': {
            'target': element.hashCode,
            'event': event,
            ...eventParams,
          },
        }),
        forLastConnection: true,
      );
    };
  }
  var isRoot = (() {
    if (widget.primary == false) {
      return false;
    } else if (widget.scrollDirection == Axis.vertical &&
        element.findAncestorWidgetOfExactType<Scrollable>() == null &&
        (() {
          final multiChildWidget = element
              .findAncestorWidgetOfKindType<MultiChildRenderObjectWidget>();
          if (multiChildWidget != null) {
            if ((multiChildWidget.key is ValueKey &&
                (multiChildWidget.key as ValueKey).value ==
                    '__ScaffoldStack')) {
              return true;
            }
            return false;
          } else {
            return true;
          }
        })()) {
      return true;
    } else {
      return false;
    }
  })();
  if (isRoot) {
    element.findAncestorStateOfType<MPScaffoldState>()?.hasRootScroller = true;
  }
  Element? appBarPinnedElement;
  var appBarPinnedPlained = false;
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
    if (scaffoldState?.appBarKey.currentWidget != null) {
      appBarPinnedElement = MPCore.findTarget<MPAppBar>(
        scaffoldState!.appBarKey.currentContext as Element?,
        findParent: true,
        maxDepth: 20,
        singleChildOnly: true,
      );
      if (appBarPinnedElement != null) appBarPinnedPlained = true;
    }
    bottomBarHeight =
        scaffoldState?.bottomBarKey.currentContext?.size?.height ?? 0.0;
    bottomBarWithSafeArea = scaffoldState?.isBottomBarWithSafeArea() ?? false;
  }
  final hasScrollNotificationListener = (() {
    var hasResult = false;
    if (widget.controller != null) {
      hasResult = true;
    }
    if (!hasResult) {
      element.visitAncestorElements((element) {
        if (element.widget is NotificationListener<ScrollNotification>) {
          hasResult = true;
        }
        return false;
      });
    }
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
  var hasReachBottom =
      element.findAncestorWidgetOfExactType<MPReachBottomListener>() != null;
  if (!hasRefreshIndicator && isRoot) {
    if (element.findAncestorWidgetOfExactType<MPScaffold>()?.onRefresh !=
        null) {
      hasRefreshIndicator = true;
      isRoot = false;
    }
  } else if (hasRefreshIndicator && isRoot) {
    isRoot = false;
  }
  if (hasRefreshIndicator || hasReachBottom) {
    MPCore.addElementToHashCodeCache(element);
  }
  return {
    'scrollDirection': widget.scrollDirection.toString(),
    'isRoot': isRoot,
    'reverse': widget.reverse,
    'scrollDisabled': widget.physics is NeverScrollableScrollPhysics,
    'appBarPinned': appBarPinnedElement != null
        ? MPElement.fromFlutterElement(appBarPinnedElement)
        : null,
    'appBarPinnedPlained': appBarPinnedPlained,
    'bottomBarHeight': bottomBarHeight,
    'bottomBarWithSafeArea': bottomBarWithSafeArea,
    'restorationId': widget.restorationId,
    'onScroll': hasScrollNotificationListener ? element.hashCode : null,
    'onRefresh': hasRefreshIndicator ? element.hashCode : null,
    'onReachBottom': hasReachBottom ? element.hashCode : null,
  };
}
