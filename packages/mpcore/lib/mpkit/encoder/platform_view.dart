part of './mpkit_encoder.dart';

MPElement _encodeMPPlatformView(Element element) {
  final widget = element.widget as MPPlatformView;
  return MPElement(
    hashCode: element.hashCode,
    flutterElement: element,
    name: widget.viewType,
    children: null,
    attributes: widget.viewAttributes,
  );
}
