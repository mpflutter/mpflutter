part of '../../mp_flutter_runtime.dart';

class _DecoratedBox extends ComponentView {
  final bool isFront;

  _DecoratedBox({
    Key? key,
    Map? data,
    required this.isFront,
    Map? parentData,
    required _MPComponentFactory componentFactory,
  }) : super(
            key: key,
            data: data,
            parentData: parentData,
            componentFactory: componentFactory);

  AlignmentGeometry _alignmentGeometryFromString(String? value) {
    switch (value) {
      case 'centerRight':
        return Alignment.centerRight;
      case 'centerLeft':
        return Alignment.centerLeft;
      case 'topRight':
        return Alignment.topRight;
      case 'bottomRight':
        return Alignment.bottomRight;
      case 'topLeft':
        return Alignment.topLeft;
      case 'bottomLeft':
        return Alignment.bottomLeft;
      case 'topCenter':
        return Alignment.topCenter;
      case 'bottomCenter':
        return Alignment.bottomCenter;
      default:
        return Alignment.topLeft;
    }
  }

  Offset _offsetFromString(String? attributeValue) {
    if (attributeValue == null) return const Offset(0, 0);
    if (attributeValue.startsWith('Offset(')) {
      final trimedValue =
          attributeValue.replaceAll("Offset(", "").replaceAll(")", "");
      final parts = trimedValue.split(',');
      return Offset(
        double.tryParse(parts[0]) ?? 0.0,
        double.tryParse(parts[1]) ?? 0.0,
      );
    }
    return const Offset(0, 0);
  }

  BorderRadius? getBorderRadiusFromValue(String attributeValue) {
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

  @override
  Widget builder(BuildContext context) {
    Color? color = getColorFromAttributes(context, 'color');
    Map? decoration = getValueFromAttributes(context, 'decoration');
    Gradient? gradient = (() {
      if (decoration != null && decoration['gradient'] is Map) {
        Map gradientData = decoration['gradient'];
        if (gradientData['classname'] == 'RadialGradient') {
          return RadialGradient(
            stops: (gradientData['stops'] as List?)?.map((e) {
              if (e is num) {
                return e.toDouble();
              } else {
                return 0.0;
              }
            }).toList(),
            colors: (gradientData['colors'] as List).map((e) {
              return _Utils.toColor(e);
            }).toList(),
          );
        } else {
          return LinearGradient(
            begin: _alignmentGeometryFromString(gradientData['begin']),
            end: _alignmentGeometryFromString(gradientData['end']),
            colors: (gradientData['colors'] as List).map((e) {
              return _Utils.toColor(e);
            }).toList(),
            stops: (gradientData['stops'] as List?)?.map((e) {
              if (e is num) {
                return e.toDouble();
              } else {
                return 0.0;
              }
            }).toList(),
          );
        }
      }
    })();
    BorderRadius? borderRadius = (() {
      if (decoration != null) {
        String? borderRadius = decoration['borderRadius'];
        if (borderRadius != null) {
          return getBorderRadiusFromValue(borderRadius);
        }
      }
    })();
    BoxBorder? boxBorder = (() {
      if (decoration != null) {
        Map? borderData = decoration['border'];
        if (borderData != null) {
          return Border(
            top: BorderSide(
              width: _Utils.toDouble(borderData['topWidth'], 0.0),
              color: _Utils.toColor(borderData['topColor']),
            ),
            left: BorderSide(
              width: _Utils.toDouble(borderData['leftWidth'], 0.0),
              color: _Utils.toColor(borderData['leftColor']),
            ),
            bottom: BorderSide(
              width: _Utils.toDouble(borderData['bottomWidth'], 0.0),
              color: _Utils.toColor(borderData['bottomColor']),
            ),
            right: BorderSide(
              width: _Utils.toDouble(borderData['rightWidth'], 0.0),
              color: _Utils.toColor(borderData['rightColor']),
            ),
          );
        }
      }
    })();
    List<BoxShadow>? boxShadow = (() {
      if (decoration != null) {
        List? boxShadowsData = decoration['boxShadow'];
        if (boxShadowsData != null) {
          return boxShadowsData
              .map((e) {
                return BoxShadow(
                  color: _Utils.toColor(e['color']),
                  offset: _offsetFromString(e['offset']),
                  blurRadius: _Utils.toDouble(e['blurRadius'], 0.0),
                );
              })
              .toList()
              .cast<BoxShadow>();
        }
      }
    })();
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        gradient: gradient,
        borderRadius: borderRadius,
        border: boxBorder,
        boxShadow: boxShadow,
      ),
      position: isFront
          ? DecorationPosition.foreground
          : DecorationPosition.background,
      child: Transform.translate(
        offset:
            Offset(boxBorder?.top.width ?? 0.0, boxBorder?.top.width ?? 0.0),
        child: getWidgetFromChildren(context),
      ),
    );
  }
}
