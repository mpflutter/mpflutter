part of '../../mp_flutter_runtime.dart';

class _ClipOval extends ComponentView {
  _ClipOval({
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
    return ClipOval(
      child: getWidgetFromChildren(context),
    );
  }
}
