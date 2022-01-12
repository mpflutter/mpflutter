part of '../../mp_flutter_runtime.dart';

class _AbsorbPointer extends ComponentView {
  _AbsorbPointer({
    Key? key,
    Map? data,
  }) : super(key: key, data: data);

  @override
  Widget builder(BuildContext context) {
    return AbsorbPointer(
      absorbing: getBoolFromAttributes(context, 'absorbing') ?? true,
      child: getWidgetFromChildren(context),
    );
  }
}
