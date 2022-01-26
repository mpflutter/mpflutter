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
  return MPElement(
    hashCode: element.hashCode,
    flutterElement: element,
    name: 'grid_view',
    children: MPElement.childrenFromFlutterElement(
      indexedSemanticeParentElement,
    ),
    attributes: {
      'scrollDirection': widget.scrollDirection.toString(),
      'padding': widget.padding?.toString(),
      'width':
          // ignore: invalid_use_of_protected_member
          (element.findRenderObject()?.constraints as BoxConstraints).maxWidth,
      'gridDelegate': _encodeGridDelegate(widget.gridDelegate),
      ..._encodeScroller(element),
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
