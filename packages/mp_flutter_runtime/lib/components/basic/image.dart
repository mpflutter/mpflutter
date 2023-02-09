part of '../../mp_flutter_runtime.dart';

class _Image extends ComponentView {
  _Image({
    Key? key,
    Map? data,
    Map? parentData,
    required _MPComponentFactory componentFactory,
  }) : super(
            key: key,
            data: data,
            parentData: parentData,
            componentFactory: componentFactory);

  Widget buildNetworkImage(BuildContext context, String src) {
    if (src.endsWith('.svg')) {
      return FutureBuilder(
        future: (() async {
          return (await DefaultCacheManager().getSingleFile(src))
              .readAsBytesSync();
        })(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return SvgPicture.memory(
              snapshot.data as Uint8List,
              fit: getFit(context),
            );
          } else {
            return const SizedBox();
          }
        },
      );
    } else {
      return getEngine(context)
              ?.provider
              .imageProvider
              .createImageWithURLString(
                  context: context, imageUrl: src, fit: getFit(context)) ??
          const SizedBox();
    }
  }

  BoxFit getFit(BuildContext context) {
    final value = getStringFromAttributes(context, 'fit');
    switch (value) {
      case 'BoxFit.contain':
        return BoxFit.contain;
      case 'BoxFit.cover':
        return BoxFit.cover;
      case 'BoxFit.fill':
        return BoxFit.fill;
      case 'BoxFit.fitHeight':
        return BoxFit.fitHeight;
      case 'BoxFit.fitWidth':
        return BoxFit.fitWidth;
      case 'BoxFit.scaleDown':
        return BoxFit.scaleDown;
      case 'BoxFit.none':
        return BoxFit.none;
      default:
        return BoxFit.contain;
    }
  }

  @override
  Widget builder(BuildContext context) {
    final src = getStringFromAttributes(context, 'src');
    final base64Data = getStringFromAttributes(context, 'base64');
    final assetName = getStringFromAttributes(context, 'assetName');
    final imageType = getStringFromAttributes(context, 'imageType');
    if (src != null) {
      return ClipRect(child: buildNetworkImage(context, src));
    } else if (base64Data != null) {
      if (imageType != null && imageType.startsWith("svg")) {
        return ClipRect(child: SvgPicture.memory(base64.decode(base64Data)));
      }
      return ClipRect(child: Image.memory(base64.decode(base64Data)));
    } else if (assetName != null) {
      final engine = getEngine(context);
      if (engine?._mpkReader != null) {
        return _MPImageWithMPKReader(
          engine!._mpkReader!,
          assetName,
          fit: getFit(context),
        );
      } else if (engine?.debugger != null) {
        final assetUrl =
            'http://${engine!.debugger!.serverAddr}/assets/$assetName';
        return ClipRect(child: buildNetworkImage(context, assetUrl));
      } else {
        return ClipRect(
            child: getEngine(context)
                    ?.provider
                    .imageProvider
                    .createImageWithAssetName(
                        context: context,
                        assetName: assetName,
                        fit: getFit(context)) ??
                const SizedBox());
      }
    }
    return const SizedBox();
  }
}
