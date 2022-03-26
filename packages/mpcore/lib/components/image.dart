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
      'base64': (() {
        if (widget.image is MemoryImage) {
          return base64.encode((widget.image as MemoryImage).bytes);
        }
      })(),
      'lazyLoad': (() {
        if (widget.image is NetworkImage) {
          return widget.lazyLoad;
        }
        return false;
      })(),
      'imageType': widget.imageType,
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
