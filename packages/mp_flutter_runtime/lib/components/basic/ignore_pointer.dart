part of '../../mp_flutter_runtime.dart';

class _IgnorePointer extends ComponentView {
  _IgnorePointer({
    Key? key,
    Map? data,
  }) : super(key: key, data: data);

  @override
  Widget builder(BuildContext context) {
    return IgnorePointer(
      ignoring: getBoolFromAttributes(context, 'ignoring') ?? true,
      child: getWidgetFromChildren(context),
    );
  }
}
