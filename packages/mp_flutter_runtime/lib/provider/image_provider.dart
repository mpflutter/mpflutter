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
