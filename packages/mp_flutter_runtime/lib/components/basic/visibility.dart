part of '../../mp_flutter_runtime.dart';

class _Visibility extends ComponentView {
  _Visibility({
    Key? key,
    Map? data,
  }) : super(key: key, data: data);

  @override
  Widget builder(BuildContext context) {
    return Visibility(
      visible: getBoolFromAttributes(context, 'visible') ?? false,
      child: getWidgetFromChildren(context) ?? const SizedBox(),
    );
  }
}
