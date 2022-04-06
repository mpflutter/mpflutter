part of 'mpkit_encoder.dart';

MPElement _encodeMPPageView(Element element) {
  MPCore.addElementToHashCodeCache(element);
  final widget = element.widget as MPPageView;
  widget.controller?.targetHashCode = element.hashCode;
  return MPElement(
    hashCode: element.hashCode,
    flutterElement: element,
    name: 'mp_page_view',
    children: (() {
      final firstChild =
          MPElement.childrenFromFlutterElement(element)[0].flutterElement;
      if (firstChild != null) {
        return MPElement.childrenFromFlutterElement(firstChild);
      }
    })(),
    attributes: {
      'scrollDirection': widget.scrollDirection.toString(),
      'loop': widget.loop,
      'autoplay': widget.autoplay,
      'initialPage': widget.controller?.initialPage ?? 0,
    },
  );
}
