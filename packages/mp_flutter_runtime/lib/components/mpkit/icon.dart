part of '../../mp_flutter_runtime.dart';

class _MPIcon extends ComponentView {
  _MPIcon({
    Key? key,
    Map? data,
  }) : super(key: key, data: data);

  @override
  Widget builder(BuildContext context) {
    final iconUrl = getStringFromAttributes(context, 'iconUrl');
    if (iconUrl == null) return const SizedBox();
    final color = getStringFromAttributes(context, 'color');
    return SvgPicture.network(
      iconUrl,
      color: color != null ? (Color(int.tryParse(color) ?? 0)) : Colors.black,
    );
  }
}
