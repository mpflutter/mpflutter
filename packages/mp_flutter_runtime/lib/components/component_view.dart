part of '../mp_flutter_runtime.dart';

class ComponentView extends StatefulWidget {
  final Map? data;
  final Widget? child;
  final int? dataHashCode;
  final bool? noLayout;

  ComponentView({
    Key? key,
    this.data,
    this.child,
    this.noLayout,
  })  : dataHashCode = (() {
          if (data?['hashCode'] is int) {
            return data!['hashCode'];
          } else {
            return null;
          }
        })(),
        super(key: key);

  Widget builder(BuildContext context) {
    return SizedBox(
      child: getWidgetFromChildren(context),
    );
  }

  MPEngine? getEngine(BuildContext context) {
    return context.findAncestorWidgetOfExactType<MPPage>()?.engine;
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
        return Color(int.tryParse(attributeValue) ?? 0);
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
      if (attributeValue is num) {
        return attributeValue.toDouble();
      }
    }
  }

  int? getIntFromAttributes(BuildContext context, String attributeKey) {
    final attributes =
        ComponentViewState.getData(context)?['attributes'] as Map?;
    if (attributes != null) {
      dynamic attributeValue = attributes[attributeKey];
      if (attributeValue is num) {
        return attributeValue.toInt();
      }
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
        return _MPComponentFactory.create(attributeValue);
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

  Widget? getWidgetFromChildren(BuildContext context) {
    final children = ComponentViewState.getData(context)?['children'] as List?;
    if (children != null) {
      if (children.length > 1) {
        return const SizedBox();
      } else if (children.length == 1) {
        return _MPComponentFactory.create(children[0]);
      }
    }
  }

  List<Widget>? getWidgetsFromChildren(BuildContext context) {
    final children = ComponentViewState.getData(context)?['children'] as List?;
    if (children != null) {
      return children.map((e) => _MPComponentFactory.create(e)).toList();
    }
  }

  @override
  ComponentViewState createState() => ComponentViewState();
}

class ComponentViewState extends State<ComponentView> {
  Map? data;

  static Map? getData(BuildContext context) {
    if (context is StatefulElement && context.state is ComponentViewState) {
      return (context.state as ComponentViewState).data;
    }
    return context.findAncestorStateOfType<ComponentViewState>()?.data;
  }

  @override
  void initState() {
    super.initState();
    data = widget.data;
  }

  @override
  void didUpdateWidget(ComponentView oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {
      data = widget.data;
    });
  }

  Widget buildLayoutWidget(Widget widget) {
    if (this.widget.noLayout == true) {
      return widget;
    }
    final constraints = data?['constraints'] as Map?;
    if (constraints != null) {
      double? x = constraints['x'];
      double? y = constraints['y'];
      double? w = constraints['w'];
      double? h = constraints['h'];
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
