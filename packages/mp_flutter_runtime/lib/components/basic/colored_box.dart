part of '../../mp_flutter_runtime.dart';

class _ColoredBox extends ComponentView {
  _ColoredBox({
    Key? key,
    Map? data,
  }) : super(key: key, data: data);

  @override
  Widget builder(BuildContext context) {
    return ColoredBox(
      color:
          getColorFromAttributes(context, 'color') ?? const Color(0x00000000),
      child: getWidgetFromChildren(context),
    );
  }
}
