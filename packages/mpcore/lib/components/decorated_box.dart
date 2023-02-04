part of '../mpcore.dart';

MPElement _encodeDecoratedBox(Element element) {
  final widget = element.widget as DecoratedBox;
  final attributes = <String, dynamic>{};
  if (widget.decoration is BoxDecoration) {
    final decoration = widget.decoration as BoxDecoration;
    if (decoration.color != null) {
      attributes['color'] = decoration.color!.value.toString();
    }
    final decoImage = decoration.image;
    if (decoImage != null) {
      attributes['image'] = (() {
        return {
          'src': (() {
            if (decoImage.image is NetworkImage) {
              return (decoImage.image as NetworkImage).url;
            }
          })(),
          'assetName': (() {
            if (decoImage.image is AssetImage) {
              return (decoImage.image as AssetImage).assetName;
            }
          })(),
          'assetPkg': (() {
            if (decoImage.image is AssetImage) {
              return (decoImage.image as AssetImage).package;
            }
          })(),
          'fit': decoImage.fit?.toString(),
        };
      })();
    }
    attributes['decoration'] = <String, dynamic>{};
    if (decoration.borderRadius != null) {
      attributes['decoration']['borderRadius'] =
          decoration.borderRadius.toString();
    }
    if (decoration.boxShadow != null) {
      attributes['decoration']['boxShadow'] = decoration.boxShadow!.map((e) {
        return {
          'color': e.color.value.toString(),
          'offset': e.offset.toString(),
          'blurRadius': e.blurRadius,
          'spreadRadius': e.spreadRadius,
        };
      }).toList();
    }
    if (decoration.border != null && decoration.border is Border) {
      attributes['decoration']['border'] = {
        'topWidth': (decoration.border as Border).top.width,
        'topColor': (decoration.border as Border).top.color.value.toString(),
        'topStyle': (decoration.border as Border).top.style.toString(),
        'leftWidth': (decoration.border as Border).left.width,
        'leftColor': (decoration.border as Border).left.color.value.toString(),
        'leftStyle': (decoration.border as Border).left.style.toString(),
        'bottomWidth': (decoration.border as Border).bottom.width,
        'bottomColor':
            (decoration.border as Border).bottom.color.value.toString(),
        'bottomStyle': (decoration.border as Border).bottom.style.toString(),
        'rightWidth': (decoration.border as Border).right.width,
        'rightColor':
            (decoration.border as Border).right.color.value.toString(),
        'rightStyle': (decoration.border as Border).right.style.toString(),
      };
    }
    if (decoration.gradient != null && decoration.gradient is LinearGradient) {
      final linearGradient = decoration.gradient as LinearGradient;
      attributes['decoration']['gradient'] = {
        'classname': 'LinearGradient',
        'begin': linearGradient.begin.toString(),
        'end': linearGradient.end.toString(),
        'colors': linearGradient.colors.map((e) => e.value.toString()).toList(),
        'stops': linearGradient.stops,
        'tileMode': linearGradient.tileMode.toString(),
      };
    } else if (decoration.gradient != null &&
        decoration.gradient is RadialGradient) {
      final radialGradient = decoration.gradient as RadialGradient;
      attributes['decoration']['gradient'] = {
        'classname': 'RadialGradient',
        'center': radialGradient.center.toString(),
        'radius': radialGradient.radius.toString(),
        'colors': radialGradient.colors.map((e) => e.value.toString()).toList(),
        'stops': radialGradient.stops,
        'tileMode': radialGradient.tileMode.toString(),
      };
    }
  }
  attributes['position'] = widget.position.toString();
  return MPElement(
    hashCode: element.hashCode,
    flutterElement: element,
    name: widget.position == DecorationPosition.foreground
        ? 'foreground_decorated_box'
        : 'decorated_box',
    children: MPElement.childrenFromFlutterElement(element),
    attributes: attributes,
  );
}
