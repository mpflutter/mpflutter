part of '../mpcore.dart';

MPElement _encodeGridView(Element element) {
  final indexedSemanticeParentElement = MPCore.findTarget<KeyedSubtree>(
    element,
    findParent: true,
    maxDepth: 20,
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

  return MPElement(
    hashCode: element.hashCode,
    flutterElement: element,
    name: 'grid_view',
    children: MPElement.childrenFromFlutterElement(
      indexedSemanticeParentElement,
    ),
    // ignore: invalid_use_of_protected_member
    constraints: element.findRenderObject()?.constraints,
    attributes: {
      'scrollDirection': widget.scrollDirection.toString(),
      'isRoot': (() {
        if (widget.primary == false) {
          return false;
        } else if (widget.scrollDirection == Axis.vertical &&
            element.findAncestorWidgetOfExactType<Scrollable>() == null &&
            element.findAncestorWidgetOfExactType<Align>() == null &&
            element.findAncestorWidgetOfExactType<Center>() == null) {
          return true;
        } else {
          return false;
        }
      })(),
      'padding': widget.padding?.toString(),
      'width':
          // ignore: invalid_use_of_protected_member
          (element.findRenderObject()?.constraints as BoxConstraints).maxWidth,
      'gridDelegate': _encodeGridDelegate(widget.gridDelegate),
    },
  );
}

MPElement _encodeSliverWaterfallItem(Element element) {
  final widget = element.widget as SliverWaterfallItem;
  var height = widget.size?.height;
  if (height == null && element.findRenderObject() is RenderBox) {
    height = (element.findRenderObject() as RenderBox).size.height;
  }
  return MPElement(
    hashCode: element.hashCode,
    flutterElement: element,
    name: 'sliver_waterfall_item',
    children: MPElement.childrenFromFlutterElement(element),
    attributes: {'height': height},
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
