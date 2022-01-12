part of '../../mp_flutter_runtime.dart';

class _MPScaffold extends ComponentView {
  _MPScaffold({
    Key? key,
    Map? data,
  }) : super(key: key, data: data);

  @override
  Widget builder(BuildContext context) {
    final body = getWidgetFromAttributes(context, 'body');
    return Scaffold(
      backgroundColor: getColorFromAttributes(context, 'backgroundColor'),
      body: body,
    );
  }
}
