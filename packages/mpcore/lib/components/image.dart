part of '../mpcore.dart';

MPElement _encodeImage(Element element) {
  final widget = element.widget as Image;
  return MPElement(
    hashCode: element.hashCode,
    flutterElement: element,
    name: 'image',
    attributes: {
      'src': (() {
        if (widget.image is NetworkImage) {
          return (widget.image as NetworkImage).url;
        }
      })(),
      'assetName': (() {
        if (widget.image is AssetImage) {
          return (widget.image as AssetImage).assetName;
        }
      })(),
      'assetPkg': (() {
        if (widget.image is AssetImage) {
          return (widget.image as AssetImage).package;
        }
      })(),
      'fit': widget.fit.toString(),
      'width': widget.width,
      'height': widget.height,
    },
  );
}
