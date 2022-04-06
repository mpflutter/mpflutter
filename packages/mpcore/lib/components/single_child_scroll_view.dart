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
  return MPElement(
    hashCode: element.hashCode,
    flutterElement: element,
    name: 'div',
    children: MPElement.childrenFromFlutterElement(
      scrollable,
    ),
    attributes: {},
  );
}
