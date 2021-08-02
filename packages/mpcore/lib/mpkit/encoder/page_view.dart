part of 'mpkit_encoder.dart';

MPElement _encodeMPPageView(Element element) {
  final widget = element.widget as MPPageView;
  final children = <Element>[];
  MPCore.findTargets<MPPageItem>(
    element,
    out: children,
  );
  return MPElement(
    hashCode: element.hashCode,
    flutterElement: element,
    name: 'mp_page_view',
    children:
        children.map((child) => MPElement.fromFlutterElement(child)).toList(),
    attributes: {
      'scrollDirection': widget.scrollDirection.toString(),
      'loop': widget.loop,
    },
  );
}
