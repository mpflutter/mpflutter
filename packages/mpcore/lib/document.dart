part of './mpcore.dart';

class _Document {
  final int? routeId;
  final MPElement? scaffold;
  final List<MPElement>? overlays;
  final List<MPElement>? diffs;

  _Document({
    this.routeId,
    this.scaffold,
    this.overlays,
    this.diffs,
  });

  Map toJson() {
    if (diffs != null) {
      return {
        'routeId': routeId,
        'diffs': diffs,
      };
    }
    return {
      'routeId': routeId,
      'scaffold': scaffold,
      'overlays': overlays,
    };
  }
}

class MPElement {
  static Map<int, MPElement> elementCache = {};
  static List<int> invalidElements = [];

  static void runElementCacheGC() {
    final theInvalidElements = elementCache.values
        .where((element) => element.flutterElement?.isInactive() == true)
        .toList();
    elementCache.removeWhere(
        (key, value) => value.flutterElement?.isInactive() == true);
    invalidElements.addAll(theInvalidElements.map((e) => e.hashCode));
  }

  @override
  final int hashCode;

  final Element? flutterElement;
  final String name;
  final List<MPElement>? children;
  final Map<String, dynamic>? attributes;

  MPElement({
    required this.hashCode,
    this.flutterElement,
    required this.name,
    this.children,
    this.attributes,
  }) {
    if (name.endsWith('_span')) {
      return;
    }
    final cachedElement = elementCache[hashCode];
    if (cachedElement != null) {
      euqalCheck(cachedElement);
    }
    elementCache[hashCode] = this;
  }

  bool? _isEqual;

  @override
  bool operator ==(Object other) {
    if (!(other is MPElement)) return false;
    euqalCheck(other);
    return _isEqual!;
  }

  void euqalCheck(MPElement other) {
    if (_isEqual != null) return;
    final result = hashCode == other.hashCode &&
        name == other.name &&
        isChildrenEqual(other) &&
        isAttributesEqual(other);
    _isEqual = result;
    other._isEqual = result;
  }

  bool isAttributesEqual(MPElement other) {
    final myKeys = attributes?.keys.toList();
    final otherKeys = other.attributes?.keys.toList();
    if (myKeys == null && otherKeys != null) return false;
    if (myKeys != null && otherKeys == null) return false;
    if (myKeys == null && otherKeys == null) return true;
    if (myKeys!.length != otherKeys!.length) return false;
    for (var i = 0; i < myKeys.length; i++) {
      if (myKeys[i] != otherKeys[i]) {
        return false;
      }
    }
    for (var i = 0; i < myKeys.length; i++) {
      if (attributes![myKeys[i]] is Map &&
          other.attributes![otherKeys[i]] is Map) {
        if (json.encode(attributes![myKeys[i]]) !=
            json.encode(other.attributes![otherKeys[i]])) {
          return false;
        }
      } else if (attributes![myKeys[i]] != other.attributes![otherKeys[i]]) {
        return false;
      }
    }
    return true;
  }

  bool isChildrenEqual(MPElement other) {
    if (children == null && other.children != null) return false;
    if (children != null && other.children == null) return false;
    if (children == null && other.children == null) return true;
    for (var i = 0; i < children!.length; i++) {
      if (i >= other.children!.length) {
        return false;
      }
      if (children![i] != other.children![i]) {
        return false;
      }
    }
    if (children!.length != other.children!.length) return false;
    return true;
  }

  Map toJson() {
    if (_isEqual == true) {
      return {
        'hashCode': hashCode,
        '^': 1,
      };
    }
    return {
      'hashCode': hashCode,
      'name': name,
      'children': children,
      'constraints': _encodeConstraints(),
      'attributes': attributes,
    };
  }

  Map? _encodeConstraints() {
    double? x, y, w, h;
    final renderBox = flutterElement?.renderObject;
    var hasConstraints = false;
    if (renderBox != null && renderBox is RenderBox) {
      if (!renderBox.hasSize) {
        renderBox.layout(renderBox.constraints);
      }
      if (renderBox.hasSize) {
        if (renderBox.parentData is BoxParentData) {
          x = (renderBox.parentData as BoxParentData).offset.dx;
          y = (renderBox.parentData as BoxParentData).offset.dy;
        } else if (renderBox.parentData is SliverPhysicalParentData) {
          x = (renderBox.parentData as SliverPhysicalParentData).paintOffset.dx;
          y = (renderBox.parentData as SliverPhysicalParentData).paintOffset.dy;
        } else {
          x = 0.0;
          y = 0.0;
        }
        w = renderBox.size.width;
        h = renderBox.size.height;
      }
      hasConstraints = true;
    }
    if (renderBox != null && renderBox is RenderSliver) {
      if (renderBox.parentData is BoxParentData) {
        x = (renderBox.parentData as BoxParentData).offset.dx;
        y = (renderBox.parentData as BoxParentData).offset.dy;
      } else if (renderBox.parentData is SliverPhysicalParentData) {
        x = (renderBox.parentData as SliverPhysicalParentData).paintOffset.dx;
        y = (renderBox.parentData as SliverPhysicalParentData).paintOffset.dy;
      } else {
        x = 0.0;
        y = 0.0;
      }
      w = renderBox.paintBounds.width;
      h = renderBox.paintBounds.height;
      hasConstraints = true;
    }
    if (hasConstraints) {
      return {
        'x': x,
        'y': y,
        'w': w,
        'h': h,
      }..removeWhere((key, value) => value == null);
    } else {
      return null;
    }
  }

  static Map<Type, MPElement Function(Element)> fromFlutterElementMethodCache =
      {};

  static MPElement fromFlutterElement(Element element) {
    if (fromFlutterElementMethodCache[element.widget.runtimeType] != null) {
      return fromFlutterElementMethodCache[element.widget.runtimeType]!(
          element);
    } else if (element.widget is ColoredBox) {
      fromFlutterElementMethodCache[element.widget.runtimeType] =
          _encodeColoredBox;
      return _encodeColoredBox(element);
    } else if (element.widget is RichText) {
      fromFlutterElementMethodCache[element.widget.runtimeType] =
          _encodeRichText;
      return _encodeRichText(element);
    } else if (element.widget is ListView) {
      fromFlutterElementMethodCache[element.widget.runtimeType] =
          _encodeListView;
      return _encodeListView(element);
    } else if (element.widget is GridView) {
      fromFlutterElementMethodCache[element.widget.runtimeType] =
          _encodeGridView;
      return _encodeGridView(element);
    } else if (element.widget is SliverWaterfallItem) {
      fromFlutterElementMethodCache[element.widget.runtimeType] =
          _encodeSliverWaterfallItem;
      return _encodeSliverWaterfallItem(element);
    } else if (element.widget is DecoratedBox) {
      fromFlutterElementMethodCache[element.widget.runtimeType] =
          _encodeDecoratedBox;
      return _encodeDecoratedBox(element);
    } else if (element.widget is Image) {
      fromFlutterElementMethodCache[element.widget.runtimeType] = _encodeImage;
      return _encodeImage(element);
    } else if (element.widget is ClipOval) {
      fromFlutterElementMethodCache[element.widget.runtimeType] =
          _encodeClipOval;
      return _encodeClipOval(element);
    } else if (element.widget is ClipRRect) {
      fromFlutterElementMethodCache[element.widget.runtimeType] =
          _encodeClipRRect;
      return _encodeClipRRect(element);
    } else if (element.widget is ClipRect) {
      fromFlutterElementMethodCache[element.widget.runtimeType] =
          _encodeClipRect;
      return _encodeClipRect(element);
    } else if (element.widget is Opacity) {
      fromFlutterElementMethodCache[element.widget.runtimeType] =
          _encodeOpacity;
      return _encodeOpacity(element);
    } else if (element.widget is SliverOpacity) {
      fromFlutterElementMethodCache[element.widget.runtimeType] =
          _encodeSliverOpacity;
      return _encodeSliverOpacity(element);
    } else if (element.widget is GestureDetector) {
      fromFlutterElementMethodCache[element.widget.runtimeType] =
          _encodeGestureDetector;
      return _encodeGestureDetector(element);
    } else if (element.widget is Visibility) {
      fromFlutterElementMethodCache[element.widget.runtimeType] =
          _encodeVisibility;
      return _encodeVisibility(element);
    } else if (element.widget is SliverVisibility) {
      fromFlutterElementMethodCache[element.widget.runtimeType] =
          _encodeSliverVisibility;
      return _encodeSliverVisibility(element);
    } else if (element.widget is Offstage) {
      fromFlutterElementMethodCache[element.widget.runtimeType] =
          _encodeOffstage;
      return _encodeOffstage(element);
    } else if (element.widget is SliverOffstage) {
      fromFlutterElementMethodCache[element.widget.runtimeType] =
          _encodeSliverOffstage;
      return _encodeSliverOffstage(element);
    } else if (element.widget is Transform) {
      fromFlutterElementMethodCache[element.widget.runtimeType] =
          _encodeTransform;
      return _encodeTransform(element);
    } else if (element.widget is IgnorePointer) {
      fromFlutterElementMethodCache[element.widget.runtimeType] =
          _encodeIgnorePointer;
      return _encodeIgnorePointer(element);
    } else if (element.widget is AbsorbPointer) {
      fromFlutterElementMethodCache[element.widget.runtimeType] =
          _encodeAbsorbPointer;
      return _encodeAbsorbPointer(element);
    } else if (element.widget is Icon) {
      fromFlutterElementMethodCache[element.widget.runtimeType] = _encodeIcon;
      return _encodeIcon(element);
    } else if (element.widget is CustomScrollView) {
      fromFlutterElementMethodCache[element.widget.runtimeType] =
          _encodeCustomScrollView;
      return _encodeCustomScrollView(element);
    } else if (element.widget is SliverList) {
      fromFlutterElementMethodCache[element.widget.runtimeType] =
          _encodeSliverList;
      return _encodeSliverList(element);
    } else if (element.widget is SliverGrid) {
      fromFlutterElementMethodCache[element.widget.runtimeType] =
          _encodeSliverGrid;
      return _encodeSliverGrid(element);
    } else if (element.widget is EditableText) {
      fromFlutterElementMethodCache[element.widget.runtimeType] =
          _encodeEditableText;
      return _encodeEditableText(element);
    } else if (element.widget is SliverPersistentHeader) {
      fromFlutterElementMethodCache[element.widget.runtimeType] =
          _encodeSliverPersistentHeader;
      return _encodeSliverPersistentHeader(element);
    } else if (element.widget is CustomPaint) {
      fromFlutterElementMethodCache[element.widget.runtimeType] =
          _encodeCustomPaint;
      return _encodeCustomPaint(element);
    } else if (_isCoordElement(element)) {
      fromFlutterElementMethodCache[element.widget.runtimeType] = _encodeCoord;
      return _encodeCoord(element);
    } else {
      final mpKitResult = MPKitEncoder.fromFlutterElement(element);
      if (mpKitResult != null) {
        return mpKitResult;
      }
      for (final plugin in MPCore._plugins) {
        final result = plugin.encodeElement(element);
        if (result != null) {
          return result;
        }
      }
      fromFlutterElementMethodCache[element.widget.runtimeType] = _encodeDivBox;
      return _encodeDivBox(element);
    }
  }

  static List<MPElement> childrenFromFlutterElement(Element element) {
    final els = <MPElement>[];
    element.visitChildElements((element) {
      final it = fromFlutterElement(element);
      els.add(it);
    });
    return els;
  }
}
