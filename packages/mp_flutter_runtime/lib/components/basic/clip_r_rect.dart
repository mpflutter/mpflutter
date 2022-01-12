part of '../../mp_flutter_runtime.dart';

class _ClipRRect extends ComponentView {
  _ClipRRect({
    Key? key,
    Map? data,
  }) : super(key: key, data: data);

  @override
  Widget builder(BuildContext context) {
    return ClipRRect(
      borderRadius: getBorderRadiusFromAttributes(context, 'borderRadius') ??
          BorderRadius.circular(0),
      child: getWidgetFromChildren(context),
    );
  }
}
