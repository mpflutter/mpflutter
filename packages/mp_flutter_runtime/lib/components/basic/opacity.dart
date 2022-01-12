part of '../../mp_flutter_runtime.dart';

class _Opacity extends ComponentView {
  _Opacity({
    Key? key,
    Map? data,
  }) : super(key: key, data: data);

  @override
  Widget builder(BuildContext context) {
    return Opacity(
      opacity: getDoubleFromAttributes(context, 'opacity') ?? 1.0,
      child: getWidgetFromChildren(context),
    );
  }
}
