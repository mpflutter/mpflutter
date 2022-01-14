part of '../../mp_flutter_runtime.dart';

class _Offstage extends ComponentView {
  _Offstage({
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
    return Offstage(
      offstage: getBoolFromAttributes(context, 'offstage') ?? true,
      child: getWidgetFromChildren(context),
    );
  }
}
