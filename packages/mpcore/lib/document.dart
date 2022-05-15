part of './mpcore.dart';

class _Document {
  final int? routeId;
  final MPElement? scaffold;
  final bool ignoreScaffold;
  final List<MPElement>? overlays;
  final List<MPElement>? diffs;

  _Document({
    this.routeId,
    this.scaffold,
    this.ignoreScaffold = false,
    this.overlays,
    this.diffs,
  });

  Map toJson() {
    if (diffs != null) {
      return {
        'routeId': routeId,
        'diffs': diffs?.map((e) => e.toJson()).toList(),
      };
    }
    return {
      'routeId': routeId,
      'scaffold': scaffold?.toJson(),
      'ignoreScaffold': ignoreScaffold,
      'overlays': overlays?.map((e) => e.toJson()).toList(),
    };
  }
}

class MPElement {
  static bool disableElementCache = false;
  static final Map<int, MPElement> _elementCache = {};
  static final Map<int, MPElement> _elementCacheNext = {};
  static final List<int> _invalidElements = [];

  static void runElementCacheGC() {
    final theInvalidElements = _elementCache.values
        .where((element) => element.flutterElement?.isInactive() == true)
        .toList();
    _elementCache.removeWhere(
        (key, value) => value.flutterElement?.isInactive() == true);
    _invalidElements.addAll(theInvalidElements.map((e) => e.hashCode));
  }

  @override
  final int hashCode;

  final int? renderObjectHashCode;
  final Element? flutterElement;
  final Rect? constraints;
  final String name;
  final List<MPElement>? children;
  final Map<String, dynamic>? attributes;

  MPElement({
    required this.hashCode,
    this.flutterElement,
    required this.name,
    this.children,
    this.attributes,
    bool mergable = false,
    Rect? additionalConstraints,
  })  : renderObjectHashCode = flutterElement?.renderObject.hashCode,
        constraints = additionalConstraints ?? _getConstraints(flutterElement) {
    if (name.endsWith('_span')) {
      return;
    }
    final cachedElement = _elementCache[hashCode];
    if (cachedElement != null) {
      euqalCheck(cachedElement);
    }
    if (disableElementCache) {
      _elementCacheNext[hashCode] = this;
    }
  }

  bool? _isEqual;

  @override
  bool operator ==(Object other) {
    if (_elementCache[hashCode] == null) return false;
    if (!(other is MPElement)) return false;
    euqalCheck(other);
    return _isEqual!;
  }

  void euqalCheck(MPElement other) {
    if (_isEqual != null) return;
    if (disableElementCache) {
      _isEqual = false;
      other._isEqual = false;
      return;
    }
    final result = hashCode == other.hashCode &&
        name == other.name &&
        isChildrenEqual(other) &&
        isAttributesEqual(other) &&
        isConstraintsEuqal(other);
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
    if (children!.length != other.children!.length) return false;
    for (var i = 0; i < children!.length; i++) {
      if (i >= other.children!.length) {
        return false;
      }
      if (children![i] != other.children![i]) {
        return false;
      }
    }
    return true;
  }

  bool isConstraintsEuqal(MPElement other) {
    return constraints == other.constraints;
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
      'widget': flutterElement?.widget.runtimeType.toString(),
      'children': children?.map((e) => e.toJson()).toList(),
      'constraints': constraints != null
          ? {
              'x': constraints!.left,
              'y': constraints!.top,
              'w': constraints!.width,
              'h': constraints!.height
            }
          : null,
      'attributes': attributes?.map((key, value) {
        if (value is MPElement) {
          return MapEntry(key, mapJson(value));
        }
        return MapEntry(key, value);
      }),
    };
  }

  dynamic mapJson(dynamic value) {
    if (value is List) {
      return value.map((e) => mapJson(e)).toList();
    } else if (value is Map) {
      return value.map((k, v) => MapEntry(k, mapJson(v)));
    } else if (value != null) {
      try {
        return (value as dynamic).toJson();
      } catch (e) {
        return null;
      }
    } else {
      return null;
    }
  }

  static Rect? _getConstraints(Element? flutterElement) {
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
      if (x != null &&
          y != null &&
          renderBox.parent?.parent is RenderDecoratedBox) {
        final renderDecorateBox =
            renderBox.parent?.parent as RenderDecoratedBox;
        if (renderDecorateBox.decoration is BoxDecoration) {
          final boxDecoration = renderDecorateBox.decoration as BoxDecoration;
          if (boxDecoration.border is Border) {
            final boxBorder = boxDecoration.border as Border;
            x -= boxBorder.left.width;
            y -= boxBorder.top.width;
          }
        }
      }
      hasConstraints = true;
    }
    if (renderBox != null && renderBox is RenderSliver) {
      if (renderBox.parentData is BoxParentData) {
        x = (renderBox.parentData as BoxParentData).offset.dx;
        y = (renderBox.parentData as BoxParentData).offset.dy;
      } else if (renderBox.parent is RenderSliver) {
        if (renderBox.constraints.axis == Axis.horizontal) {
          x = renderBox.constraints.precedingScrollExtent -
              (renderBox.parent as RenderSliver)
                  .constraints
                  .precedingScrollExtent;
          y = (renderBox.parentData as SliverPhysicalParentData).paintOffset.dy;
        } else {
          x = (renderBox.parentData as SliverPhysicalParentData).paintOffset.dx;
          y = renderBox.constraints.precedingScrollExtent -
              (renderBox.parent as RenderSliver)
                  .constraints
                  .precedingScrollExtent;
        }
      } else {
        x = 0.0;
        y = 0.0;
      }
      if (renderBox.constraints.axis == Axis.horizontal) {
        w = renderBox.geometry?.maxPaintExtent ?? 0.0;
        h = renderBox.paintBounds.height;
      } else {
        w = renderBox.paintBounds.width;
        h = renderBox.geometry?.maxPaintExtent ?? 0.0;
      }
      hasConstraints = true;
    }
    var isRootElement = true;
    var currentElement = flutterElement?.getParent();
    while (currentElement != null && currentElement.renderObject == renderBox) {
      if (fromFlutterElementMethodCache[currentElement.widget] != null ||
          _searchTypeFromFlutterElement(currentElement) != null) {
        isRootElement = false;
        break;
      }
      currentElement = currentElement.getParent();
    }
    if (!isRootElement) {
      x = 0.0;
      y = 0.0;
    }
    if (hasConstraints) {
      return Rect.fromLTWH(x ?? 0.0, y ?? 0.0, w ?? 0.0, h ?? 0.0);
    } else {
      return null;
    }
  }

  static Map<Type, MPElement Function(Element)> fromFlutterElementMethodCache =
      {
    ColoredBox: _encodeColoredBox,
    RichText: _encodeRichText,
    ListView: _encodeListView,
    SingleChildScrollView: _encodeSingleChildScrollView,
    GridView: _encodeGridView,
    DecoratedBox: _encodeDecoratedBox,
    Image: _encodeImage,
    ClipOval: _encodeClipOval,
    ClipRRect: _encodeClipRRect,
    ClipRect: _encodeClipRect,
    Opacity: _encodeOpacity,
    SliverOpacity: _encodeSliverOpacity,
    GestureDetector: _encodeGestureDetector,
    Visibility: _encodeVisibility,
    SliverVisibility: _encodeSliverVisibility,
    Offstage: _encodeOffstage,
    SliverOffstage: _encodeSliverOffstage,
    Transform: _encodeTransform,
    IgnorePointer: _encodeIgnorePointer,
    AbsorbPointer: _encodeAbsorbPointer,
    Icon: _encodeIcon,
    CustomScrollView: _encodeCustomScrollView,
    SliverList: _encodeSliverList,
    SliverGrid: _encodeSliverGrid,
    EditableText: _encodeEditableText,
    SliverPersistentHeader: _encodeSliverPersistentHeader,
    CustomPaint: _encodeCustomPaint,
    MouseRegion: _encodeMouseRegion,
  }..addAll(MPKitEncoder.fromFlutterElementMethodCache);

  static final Map<Type, Type> _searchCache = {};

  static Type? _searchTypeFromFlutterElement(Element element) {
    final widget = element.widget;
    final runtimeType = element.widget.runtimeType;
    if (_searchCache[runtimeType] != null) {
      return _searchCache[runtimeType];
    }
    try {
      Type? t;
      if (widget is ColoredBox) {
        t = ColoredBox;
      } else if (widget is ColoredBox) {
        t = ColoredBox;
      } else if (widget is RichText) {
        t = RichText;
      } else if (widget is ListView) {
        t = ListView;
      } else if (widget is SingleChildScrollView) {
        t = SingleChildScrollView;
      } else if (widget is GridView) {
        t = GridView;
      } else if (widget is DecoratedBox) {
        t = DecoratedBox;
      } else if (widget is Image) {
        t = Image;
      } else if (widget is ClipOval) {
        t = ClipOval;
      } else if (widget is ClipRRect) {
        t = ClipRRect;
      } else if (widget is ClipRect) {
        t = ClipRect;
      } else if (widget is Opacity) {
        t = Opacity;
      } else if (widget is SliverOpacity) {
        t = SliverOpacity;
      } else if (widget is GestureDetector) {
        t = GestureDetector;
      } else if (widget is MouseRegion) {
        t = MouseRegion;
      } else if (widget is Visibility) {
        t = Visibility;
      } else if (widget is SliverVisibility) {
        t = SliverVisibility;
      } else if (widget is Offstage) {
        t = Offstage;
      } else if (widget is SliverOffstage) {
        t = SliverOffstage;
      } else if (widget is Transform) {
        t = Transform;
      } else if (widget is IgnorePointer) {
        t = IgnorePointer;
      } else if (widget is AbsorbPointer) {
        t = AbsorbPointer;
      } else if (widget is Icon) {
        t = Icon;
      } else if (widget is CustomScrollView) {
        t = CustomScrollView;
      } else if (widget is SliverList) {
        t = SliverList;
      } else if (widget is SliverGrid) {
        t = SliverGrid;
      } else if (widget is EditableText) {
        t = EditableText;
      } else if (widget is SliverPersistentHeader) {
        t = SliverPersistentHeader;
      } else if (widget is CustomPaint) {
        t = CustomPaint;
      } else if (widget is MPScaffold) {
        t = MPScaffold;
      } else if (widget is MPPageView) {
        t = MPPageView;
      } else if (widget is MPIcon) {
        t = MPIcon;
      } else if (widget is MPPlatformView) {
        t = MPPlatformView;
      }
      if (t != null) {
        _searchCache[runtimeType] = t;
        return t;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static MPElement fromFlutterElement(Element element) {
    if (fromFlutterElementMethodCache[element.widget.runtimeType] != null) {
      return fromFlutterElementMethodCache[element.widget.runtimeType]!(
          element);
    } else if (_searchTypeFromFlutterElement(element) != null) {
      return fromFlutterElementMethodCache[
          _searchTypeFromFlutterElement(element)]!(element);
    } else if (_isCoordElement(element)) {
      return _encodeCoord(element);
    } else {
      for (final plugin in MPCore._plugins) {
        final result = plugin.encodeElement(element);
        if (result != null) {
          return result;
        }
      }
      return _encodeDivBox(element);
    }
  }

  static List<MPElement> childrenFromFlutterElement(Element element) {
    final els = <MPElement>[];
    element.visitChildElements((element) {
      final it = fromFlutterElement(element);
      if (it.constraints != null &&
          it.constraints!.size.isEmpty &&
          it.children?.isEmpty == true) {
        return;
      }
      if (it.name == 'coord' && (it.children == null || it.children!.isEmpty)) {
        return;
      }
      els.add(it);
    });
    return els;
  }

  static MPElement mergeSingleChildElements(MPElement element) {
    if (element.flutterElement?.findRenderObject()?.parent
        is RenderRepaintBoundary) {
      return element;
    } else if (element.flutterElement?.findRenderObject()?.parent
        is RenderSliver) {
      return element;
    }
    return element;
  }
}
