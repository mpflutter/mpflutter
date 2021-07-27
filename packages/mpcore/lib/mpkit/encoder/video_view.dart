part of './mpkit_encoder.dart';

MPElement _encodeMPVideoView(Element element) {
  final widget = element.widget as MPVideoView;
  return MPElement(
    hashCode: element.hashCode,
    flutterElement: element,
    name: 'mp_video_view',
    // ignore: invalid_use_of_protected_member
    constraints: element.findRenderObject()?.constraints,
    children: MPElement.childrenFromFlutterElement(element),
    attributes: {
      'url': widget.url,
      'controls': widget.controls,
      'autoplay': widget.autoplay,
      'loop': widget.loop,
      'muted': widget.muted,
      'poster': widget.poster,
    },
  );
}
