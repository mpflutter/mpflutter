part of '../mpcore.dart';

MPElement _encodeTransform(Element element) {
  final widget = element.widget as Transform;
  final a = widget.transform.storage[0];
  final b = widget.transform.storage[1];
  final c = widget.transform.storage[4];
  final d = widget.transform.storage[5];
  final tx = widget.transform.storage[12];
  final ty = widget.transform.storage[13];
  return MPElement(
    hashCode: element.hashCode,
    flutterElement: element,
    name: 'transform',
    children: MPElement.childrenFromFlutterElement(element),
    attributes: {
      'transform':
          'matrix(${a.toStringAsFixed(6)},${b.toStringAsFixed(6)},${c.toStringAsFixed(6)},${d.toStringAsFixed(6)},${tx.toStringAsFixed(6)},${ty.toStringAsFixed(6)})',
    },
  );
}
