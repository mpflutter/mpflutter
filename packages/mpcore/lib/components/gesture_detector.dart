part of '../mpcore.dart';

MPElement _encodeGestureDetector(Element element) {
  MPCore.addElementToHashCodeCache(element);
  final widget = element.widget as GestureDetector;
  return MPElement(
    hashCode: element.hashCode,
    flutterElement: element,
    name: 'gesture_detector',
    children: MPElement.childrenFromFlutterElement(element),
    attributes: {
      'onTap': widget.onTap != null ? element.hashCode : null,
      'onLongPress': widget.onLongPress != null ? element.hashCode : null,
      'onLongPressStart':
          widget.onLongPressStart != null ? element.hashCode : null,
      'onLongPressMoveUpdate':
          widget.onLongPressMoveUpdate != null ? element.hashCode : null,
      'onLongPressEnd': widget.onLongPressEnd != null ? element.hashCode : null,
      'onPanStart': widget.onPanStart != null ? element.hashCode : null,
      'onPanUpdate': widget.onPanUpdate != null ? element.hashCode : null,
      'onPanEnd': widget.onPanEnd != null ? element.hashCode : null,
    },
  );
}
