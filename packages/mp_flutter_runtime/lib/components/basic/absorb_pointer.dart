part of '../../mp_flutter_runtime.dart';

class _AbsorbPointer extends ComponentView {
  _AbsorbPointer({
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
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {},
      // absorbing: getBoolFromAttributes(context, 'absorbing') ?? true,
      child: getWidgetFromChildren(context),
    );
  }
}
