part of '../mp_flutter_runtime.dart';

class ComponentView extends StatefulWidget {
  final _MPComponentFactory componentFactory;
  final Map? data;
  final Map? parentData;
  final Widget? child;
  final int? dataHashCode;
  final bool? noLayout;
  final Offset? adjustOffset;

  ComponentView({
    Key? key,
    required this.componentFactory,
    this.data,
    this.parentData,
    this.child,
    this.noLayout,
  })  : dataHashCode = (() {
          if (data?['hashCode'] is int) {
            return data!['hashCode'];
          } else {
            return null;
          }
        })(),
        adjustOffset = (() {
          if (parentData != null && parentData['adjustOffset'] is Offset) {
            return parentData['adjustOffset'] as Offset;
          }
        })(),
        super(
          key: key ?? Key('mp_${data?['hashCode'] ?? Random().nextDouble()}'),
        );

  Widget builder(BuildContext context) {
    List<Widget>? children = getWidgetsFromChildren(context);
    if (children != null && children.isNotEmpty) {
      if (children.length > 1) {
        return Stack(children: children);
      } else {
        return children[0];
      }
    }
    return const SizedBox();
  }

  MPEngine? getEngine(BuildContext context) {
    return componentFactory.engine;
  }

  Size getSize() {
    final constraints = data?['constraints'] as Map?;
    if (constraints != null) {
      double? w = _Utils.toDouble(constraints['w']);
      double? h = _Utils.toDouble(constraints['h']);
      if (w != null && h != null) {
        return Size(w, h);
      }
    }
    return const Size(0, 0);
  }

  Offset getOffset() {
    final constraints = data?['constraints'] as Map?;
    if (constraints != null) {
      double? x = _Utils.toDouble(constraints['x']);
      double? y = _Utils.toDouble(constraints['y']);
      if (x != null && y != null) {
        return Offset(x, y);
      }
    }
    return const Offset(0, 0);
  }

  dynamic getValueFromAttributes(BuildContext context, String attributeKey) {
    final attributes =
        ComponentViewState.getData(context)?['attributes'] as Map?;
    if (attributes != null) {
      return attributes[attributeKey];
    }
  }

  Color? getColorFromAttributes(BuildContext context, String attributeKey) {
    final attributes =
        ComponentViewState.getData(context)?['attributes'] as Map?;
    if (attributes != null) {
      dynamic attributeValue = attributes[attributeKey];
      if (attributeValue is String) {
        return _Utils.toColor(attributeValue);
      }
    }
  }

  bool? getBoolFromAttributes(BuildContext context, String attributeKey) {
    final attributes =
        ComponentViewState.getData(context)?['attributes'] as Map?;
    if (attributes != null) {
      dynamic attributeValue = attributes[attributeKey];
      if (attributeValue is bool) {
        return attributeValue;
      }
    }
  }

  double? getDoubleFromAttributes(BuildContext context, String attributeKey) {
    final attributes =
        ComponentViewState.getData(context)?['attributes'] as Map?;
    if (attributes != null) {
      dynamic attributeValue = attributes[attributeKey];
      return _Utils.toDouble(attributeValue);
    }
  }

  int? getIntFromAttributes(BuildContext context, String attributeKey) {
    final attributes =
        ComponentViewState.getData(context)?['attributes'] as Map?;
    if (attributes != null) {
      dynamic attributeValue = attributes[attributeKey];
      return _Utils.toInt(attributeValue);
    }
  }

  String? getStringFromAttributes(BuildContext context, String attributeKey) {
    final attributes =
        ComponentViewState.getData(context)?['attributes'] as Map?;
    if (attributes != null) {
      dynamic attributeValue = attributes[attributeKey];
      if (attributeValue is String) {
        return attributeValue;
      }
    }
  }

  Widget? getWidgetFromAttributes(BuildContext context, String attributeKey) {
    final attributes =
        ComponentViewState.getData(context)?['attributes'] as Map?;
    if (attributes != null) {
      dynamic attributeValue = attributes[attributeKey];
      if (attributeValue is Map) {
        return componentFactory.create(attributeValue);
      }
    }
  }

  BorderRadius? getBorderRadiusFromAttributes(
      BuildContext context, String attributeKey) {
    final attributes =
        ComponentViewState.getData(context)?['attributes'] as Map?;
    if (attributes != null) {
      dynamic attributeValue = attributes[attributeKey];
      if (attributeValue is String) {
        if (attributeValue.startsWith('BorderRadius.circular(')) {
          final trimedValue = attributeValue
              .replaceAll("BorderRadius.circular(", "")
              .replaceAll(")", "");
          return BorderRadius.circular(double.tryParse(trimedValue) ?? 0);
        } else if (attributeValue.startsWith('BorderRadius.all(')) {
          final trimedValue = attributeValue
              .replaceAll("BorderRadius.all(", "")
              .replaceAll(")", "");
          return BorderRadius.circular(double.tryParse(trimedValue) ?? 0);
        } else if (attributeValue.startsWith('BorderRadius.only(')) {
          final trimedValue = attributeValue
              .replaceAll("BorderRadius.only(", "")
              .replaceAll("Radius.circular(", "")
              .replaceAll(")", "");
          final tl = _floatFromRegularFirstObject(
              RegExp('topLeft: ([0-9|.]+)'), trimedValue);
          final bl = _floatFromRegularFirstObject(
              RegExp('bottomLeft: ([0-9|.]+)'), trimedValue);
          final br = _floatFromRegularFirstObject(
              RegExp('bottomRight: ([0-9|.]+)'), trimedValue);
          final tr = _floatFromRegularFirstObject(
              RegExp('topRight: ([0-9|.]+)'), trimedValue);
          return BorderRadius.only(
            topLeft: Radius.circular(tl),
            bottomLeft: Radius.circular(bl),
            bottomRight: Radius.circular(br),
            topRight: Radius.circular(tr),
          );
        }
      }
    }
  }

  EdgeInsets? getEdgeInsetsFromAttributes(
      BuildContext context, String attributeKey) {
    final attributes =
        ComponentViewState.getData(context)?['attributes'] as Map?;
    if (attributes != null) {
      dynamic attributeValue = attributes[attributeKey];
      if (attributeValue is String) {
        if (attributeValue.startsWith('EdgeInsets.all(')) {
          final trimedValue = attributeValue
              .replaceAll("EdgeInsets.all(", "")
              .replaceAll(")", "");
          return EdgeInsets.all(double.tryParse(trimedValue) ?? 0);
        } else if (attributeValue.startsWith('EdgeInsets(')) {
          final trimedValue =
              attributeValue.replaceAll("EdgeInsets(", "").replaceAll(")", "");
          final parts = trimedValue.split(',');
          return EdgeInsets.fromLTRB(
            double.tryParse(parts[0]) ?? 0.0,
            double.tryParse(parts[1]) ?? 0.0,
            double.tryParse(parts[2]) ?? 0.0,
            double.tryParse(parts[3]) ?? 0.0,
          );
        }
      }
    }
  }

  Matrix4? getTransformMatrixFromAttributes(
      BuildContext context, String attributeKey) {
    final attributes =
        ComponentViewState.getData(context)?['attributes'] as Map?;
    if (attributes != null) {
      dynamic attributeValue = attributes[attributeKey];
      if (attributeValue is String) {
        String trimedValue =
            attributeValue.replaceAll("matrix(", "").replaceAll(")", "");
        List<String> values = trimedValue.split(",");
        if (values.length == 6) {
          return Matrix4.fromList([
            double.tryParse(values[0]) ?? 1.0,
            double.tryParse(values[1]) ?? 0.0,
            0,
            0,
            double.tryParse(values[2]) ?? 0.0,
            double.tryParse(values[3]) ?? 1.0,
            0,
            0,
            0,
            0,
            1,
            0,
            double.tryParse(values[4]) ?? 0.0,
            double.tryParse(values[5]) ?? 0.0,
            0,
            1,
          ]);
        }
      }
    }
  }

  double _floatFromRegularFirstObject(RegExp pattern, String text) {
    final matches = pattern.allMatches(text);
    if (matches.isEmpty) {
      return 0.0;
    }
    return double.tryParse(matches.first.group(1) ?? "") ?? 0.0;
  }

  Widget? getWidgetFromChildren(BuildContext context, {Map? parentData}) {
    final children = ComponentViewState.getData(context)?['children'] as List?;
    if (children != null) {
      if (children.length > 1) {
        return const SizedBox();
      } else if (children.length == 1) {
        return componentFactory.create(children[0], parentData: parentData);
      }
    }
  }

  List<Widget>? getWidgetsFromChildren(BuildContext context,
      {Map? parentData}) {
    final children = ComponentViewState.getData(context)?['children'] as List?;
    if (children != null) {
      return children
          .map((e) => componentFactory.create(e, parentData: parentData))
          .toList();
    }
  }

  @override
  ComponentViewState createState() => ComponentViewState();
}

class ComponentViewState extends State<ComponentView> {
  Map? data;
  final stateConfiguration = {};

  static Map? getData(BuildContext context) {
    if (context is StatefulElement && context.state is ComponentViewState) {
      return (context.state as ComponentViewState).data;
    }
    return context.findAncestorStateOfType<ComponentViewState>()?.data;
  }

  static ComponentViewState? getState(BuildContext context) {
    if (context is StatefulElement && context.state is ComponentViewState) {
      return (context.state as ComponentViewState);
    }
    return context.findAncestorStateOfType<ComponentViewState>();
  }

  @override
  void dispose() {
    if (widget.dataHashCode != null) {
      widget.componentFactory._cacheViews.remove(widget.dataHashCode!);
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    data = widget.data;
    if (widget.dataHashCode != null) {
      widget.componentFactory._cacheViews[widget.dataHashCode!] = this;
    }
  }

  @override
  void didUpdateWidget(ComponentView oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {
      data = widget.data;
    });
  }

  void updateData(Map? newData) {
    setState(() {
      if (!mounted) return;
      if (newData != null) {
        data?.addAll(newData);
      }
    });
  }

  void updateSubData(String subKey, Map? newData) {
    setState(() {
      if (!mounted) return;
      if (newData != null) {
        final subData = data?[subKey];
        if (subData is Map) {
          subData.addAll(newData);
        }
      }
    });
  }

  Widget buildLayoutWidget(Widget widget) {
    if (this.widget.noLayout == true) {
      return widget;
    }
    final constraints = data?['constraints'] as Map?;
    if (constraints != null) {
      double? x = _Utils.toDouble(constraints['x']);
      double? y = _Utils.toDouble(constraints['y']);
      double? w = _Utils.toDouble(constraints['w']);
      double? h = _Utils.toDouble(constraints['h']);
      if (this.widget.adjustOffset != null) {
        if (x != null) {
          x += this.widget.adjustOffset!.dx;
        }
        if (y != null) {
          y += this.widget.adjustOffset!.dy;
        }
      }
      if (w != null && h != null && (w > 0 && h > 0)) {
        widget = Container(
          alignment: Alignment.topLeft,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: w,
              minHeight: h,
              maxWidth: w,
              maxHeight: h,
            ),
            child: widget,
          ),
        );
      }
      if (x != null && y != null && (x > 0 || y > 0)) {
        widget = Transform.translate(
          offset: Offset(x, y),
          child: widget,
        );
      }
    }
    return widget;
  }

  @override
  Widget build(BuildContext context) {
    return buildLayoutWidget(widget.child ?? widget.builder(context));
  }
}
