part of '../../mp_flutter_runtime.dart';

class _MPIcon extends ComponentView {
  _MPIcon({
    Key? key,
    Map? data,
    Map? parentData,
    required _MPComponentFactory componentFactory,
  }) : super(
            key: key,
            data: data,
            parentData: parentData,
            componentFactory: componentFactory);

  @override
  Widget builder(BuildContext context) {
    final iconUrl = getStringFromAttributes(context, 'iconUrl');
    if (iconUrl == null) return const SizedBox();
    final color = getStringFromAttributes(context, 'color');
    return FutureBuilder(
      future: (() async {
        return (await DefaultCacheManager().getSingleFile(iconUrl))
            .readAsBytesSync();
      })(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return SvgPicture.memory(
            snapshot.data as Uint8List,
            color: color != null ? _Utils.toColor(color) : Colors.black,
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }
}
