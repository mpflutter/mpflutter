part of '../../mp_flutter_runtime.dart';

class _MPScaffold extends ComponentView {
  _MPScaffold({
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
    final body = getWidgetFromAttributes(context, 'body');
    return Scaffold(
      backgroundColor: getColorFromAttributes(context, 'backgroundColor'),
      body: body,
    );
  }
}
