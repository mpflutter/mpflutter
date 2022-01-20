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

  Widget buildNetworkImage(String src) {
    if (src.endsWith('.svg')) {
      return FutureBuilder(
        future: (() async {
          return (await DefaultCacheManager().getSingleFile(src))
              .readAsBytesSync();
        })(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return SvgPicture.memory(snapshot.data as Uint8List);
          } else {
            return const SizedBox();
          }
        },
      );
    } else {
      return CachedNetworkImage(imageUrl: src);
    }
  }

  @override
  Widget builder(BuildContext context) {
    final src = getStringFromAttributes(context, 'src');
    final base64Data = getStringFromAttributes(context, 'base64');
    final assetName = getStringFromAttributes(context, 'assetName');
    if (src != null) {
      return buildNetworkImage(src);
    } else if (base64Data != null) {
      return Image.memory(base64.decode(base64Data));
    } else if (assetName != null) {
      final engine = getEngine(context);
      if (engine?._debugger != null) {
        final assetUrl =
            'http://${engine!._debugger!.serverAddr}/assets/$assetName';
        return buildNetworkImage(assetUrl);
      } else {
        return const SizedBox();
      }
    } else {
      return const SizedBox();
    }
  }
}
