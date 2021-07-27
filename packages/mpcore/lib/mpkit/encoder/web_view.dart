part of './mpkit_encoder.dart';

MPElement _encodeMPWebView(Element element) {
  final widget = element.widget as MPWebView;
  return MPElement(
    hashCode: element.hashCode,
    flutterElement: element,
    name: 'mp_web_view',
    // ignore: invalid_use_of_protected_member
    constraints: element.findRenderObject()?.constraints,
    children: MPElement.childrenFromFlutterElement(element),
    attributes: {
      'url': widget.url,
    },
  );
}
