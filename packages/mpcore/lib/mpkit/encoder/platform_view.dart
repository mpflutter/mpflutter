part of './mpkit_encoder.dart';

MPElement _encodeMPPlatformView(Element element) {
  MPCore.addElementToHashCodeCache(element);
  final widget = element.widget as MPPlatformView;
  widget.controller?.targetHashCode = element.hashCode;
  final layoutConstraints = {};
  // ignore: invalid_use_of_protected_member
  final renderObjectConstraints = element.renderObject?.constraints;
  if (renderObjectConstraints is BoxConstraints) {
    layoutConstraints['minWidth'] = renderObjectConstraints.minWidth.toString();
    layoutConstraints['maxWidth'] = renderObjectConstraints.maxWidth.toString();
    layoutConstraints['minHeight'] =
        renderObjectConstraints.minHeight.toString();
    layoutConstraints['maxHeight'] =
        renderObjectConstraints.maxHeight.toString();
  }
  return MPElement(
    hashCode: element.hashCode,
    flutterElement: element,
    name: widget.viewType,
    children: widget.children != null
        ? (() {
            final firstChild =
                MPElement.childrenFromFlutterElement(element)[0].flutterElement;
            if (firstChild != null) {
              return MPElement.childrenFromFlutterElement(firstChild);
            }
          })()
        : MPElement.childrenFromFlutterElement(element),
    attributes: widget.viewAttributes
      ..addAll({'layoutConstraints': layoutConstraints}),
  );
}
