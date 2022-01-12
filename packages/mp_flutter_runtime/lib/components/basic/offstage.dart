part of '../../mp_flutter_runtime.dart';

class _Offstage extends ComponentView {
  _Offstage({
    Key? key,
    Map? data,
  }) : super(key: key, data: data);

  @override
  Widget builder(BuildContext context) {
    return Offstage(
      offstage: getBoolFromAttributes(context, 'offstage') ?? true,
      child: getWidgetFromChildren(context),
    );
  }
}
