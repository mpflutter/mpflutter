part of '../../mp_flutter_runtime.dart';

class _IgnorePointer extends ComponentView {
  _IgnorePointer({
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
    return IgnorePointer(
      ignoring: getBoolFromAttributes(context, 'ignoring') ?? true,
      child: getWidgetFromChildren(context),
    );
  }
}
