part of '../mp_flutter_runtime.dart';

class MPImageProvider {
  Widget createImageWithURLString({
    required BuildContext context,
    String? imageUrl,
    BoxFit? fit,
  }) {
    if (imageUrl == null) return const SizedBox();
    return CachedNetworkImage(imageUrl: imageUrl, fit: fit);
  }

  Widget createImageWithAssetName({
    required BuildContext context,
    String? assetName,
    BoxFit? fit,
  }) {
    if (assetName == null) return const SizedBox();
    return Image.asset(assetName, fit: fit);
  }
}

class _MPImageWithMPKReader extends StatefulWidget {
  final _MPKReader reader;
  final String assetName;
  final BoxFit fit;

  _MPImageWithMPKReader(
    this.reader,
    this.assetName, {
    this.fit = BoxFit.contain,
  }) : super(key: Key('MPKReader_$assetName'));

  @override
  State<_MPImageWithMPKReader> createState() => _MPImageWithMPKReaderState();
}

class _MPImageWithMPKReaderState extends State<_MPImageWithMPKReader> {
  Uint8List? data;

  @override
  initState() {
    super.initState();
    data = widget.reader.dataWithFilePath(widget.assetName);
  }

  @override
  Widget build(BuildContext context) {
    if (data == null) return const SizedBox();
    return ClipRect(
      child: Image.memory(
        data!,
        fit: widget.fit,
      ),
    );
  }
}
