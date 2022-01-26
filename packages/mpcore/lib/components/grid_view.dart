part of '../mpcore.dart';

MPElement _encodeGridView(Element element) {
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
      name: 'grid_view',
      children: [],
      attributes: {},
    );
  }
  final widget = element.widget as GridView;
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
  final refreshIndicator =
      element.findAncestorWidgetOfExactType<MPRefreshIndicator>();
  final hasRefreshIndicator = refreshIndicator != null &&
      refreshIndicator.enableChecker?.call(element.widget.key) != false;
  if (hasRefreshIndicator) {
    MPCore.addElementToHashCodeCache(element);
  }
  return MPElement(
    hashCode: element.hashCode,
    flutterElement: element,
    name: 'grid_view',
    children: MPElement.childrenFromFlutterElement(
      indexedSemanticeParentElement,
    ),
    attributes: {
      'scrollDirection': widget.scrollDirection.toString(),
      'isRoot': isRoot,
      'appBarPinned': appBarPinnedElement != null
          ? MPElement.fromFlutterElement(appBarPinnedElement)
          : null,
      'bottomBarHeight': bottomBarHeight,
      'bottomBarWithSafeArea': bottomBarWithSafeArea,
      'padding': widget.padding?.toString(),
      'width':
          // ignore: invalid_use_of_protected_member
          (element.findRenderObject()?.constraints as BoxConstraints).maxWidth,
      'gridDelegate': _encodeGridDelegate(widget.gridDelegate),
      'restorationId': widget.restorationId,
      'onScroll': hasScrollNotificationListener ? element.hashCode : null,
      'onRefresh': hasRefreshIndicator ? element.hashCode : null,
    },
  );
}

Map? _encodeGridDelegate(dynamic delegate) {
  if (delegate == null) return null;
  if (delegate is SliverWaterfallDelegate) {
    return {
      'classname': 'SliverWaterfallDelegate',
      'mainAxisSpacing': delegate.mainAxisSpacing,
      'crossAxisSpacing': delegate.crossAxisSpacing,
      'crossAxisCount': delegate.crossAxisCount,
    };
  } else if (delegate is SliverGridDelegateWithFixedCrossAxisCount) {
    return {
      'classname': 'SliverGridDelegateWithFixedCrossAxisCount',
      'mainAxisSpacing': delegate.mainAxisSpacing,
      'crossAxisSpacing': delegate.crossAxisSpacing,
      'crossAxisCount': delegate.crossAxisCount,
      'childAspectRatio': delegate.childAspectRatio,
    };
  } else if (delegate is SliverGridDelegateWithMaxCrossAxisExtent) {
    return {
      'classname': 'SliverGridDelegateWithMaxCrossAxisExtent',
      'mainAxisSpacing': delegate.mainAxisSpacing,
      'crossAxisSpacing': delegate.crossAxisSpacing,
      'maxCrossAxisExtent': delegate.maxCrossAxisExtent,
      'childAspectRatio': delegate.childAspectRatio,
    };
  } else {
    return null;
  }
}
