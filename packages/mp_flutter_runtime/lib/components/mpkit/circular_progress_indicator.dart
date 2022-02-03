part of '../../mp_flutter_runtime.dart';

class _MPCircularProgressIndicator extends ComponentView {
  _MPCircularProgressIndicator({
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
    final color = getStringFromAttributes(context, 'color');
    return getEngine(context)
            ?.provider
            .uiProvider
            .createCircularProgressIndicator(
              context: context,
              color: _Utils.toColor(color),
              size: getDoubleFromAttributes(context, 'size'),
            ) ??
        const SizedBox();
  }
}
