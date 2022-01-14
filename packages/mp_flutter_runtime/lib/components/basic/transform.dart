part of '../../mp_flutter_runtime.dart';

class _Transform extends ComponentView {
  _Transform({
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
    return Transform(
      transform: getTransformMatrixFromAttributes(context, 'transform') ??
          Matrix4.identity(),
      alignment: Alignment.center,
      child: getWidgetFromChildren(context),
    );
  }
}
