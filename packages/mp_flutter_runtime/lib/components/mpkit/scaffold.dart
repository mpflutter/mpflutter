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
    final bottomBar = getWidgetFromAttributes(context, 'bottomBar');
    final appBar = getWidgetFromAttributes(context, 'appBar');
    final floatingBody = getWidgetFromAttributes(context, 'floatingBody');
    final children = <Widget>[];
    if (body != null) {
      children.add(body);
    }
    if (bottomBar != null) {
      children.add(bottomBar);
    }
    if (appBar != null) {
      children.add(appBar);
    }
    if (floatingBody != null) {
      children.add(floatingBody);
    }
    return Scaffold(
      backgroundColor: getColorFromAttributes(context, 'backgroundColor'),
      appBar: getEngine(context)?.provider.uiProvider.createAppBar(
            context: context,
            title: getStringFromAttributes(context, 'name'),
          ),
      body: Stack(children: children),
    );
  }
}
