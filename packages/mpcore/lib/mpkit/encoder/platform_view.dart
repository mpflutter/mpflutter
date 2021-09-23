part of './mpkit_encoder.dart';

MPElement _encodeMPPlatformView(Element element) {
  MPCore.addElementToHashCodeCache(element);
  final widget = element.widget as MPPlatformView;
  widget.controller?.targetHashCode = element.hashCode;
  return MPElement(
    hashCode: element.hashCode,
    flutterElement: element,
    name: widget.viewType,
    children: MPElement.childrenFromFlutterElement(element),
    attributes: widget.viewAttributes,
  );
}
