part of './mpkit_encoder.dart';

MPElement _encodeMPIcon(Element element) {
  final widget = element.widget as MPIcon;
  return MPElement(
    hashCode: element.hashCode,
    flutterElement: element,
    name: 'mp_icon',
    children: MPElement.childrenFromFlutterElement(element),
    attributes: {
      'iconUrl': widget.iconUrl,
      'size': widget.size,
      'color': widget.color.value.toString(),
    },
  );
}
