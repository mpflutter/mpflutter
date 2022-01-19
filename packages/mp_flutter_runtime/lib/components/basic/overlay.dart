part of '../../mp_flutter_runtime.dart';

class _Overlay extends ComponentView {
  _Overlay({
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
      onTap: () {
        final onBackgroundTap =
            getIntFromAttributes(context, 'onBackgroundTap');
        if (onBackgroundTap != null) {
          componentFactory.engine._sendMessage({
            'type': 'overlay',
            'message': {
              'event': 'onBackgroundTap',
              'target': onBackgroundTap,
            },
          });
        }
      },
      child: Container(
        color: Colors.transparent,
        child: getWidgetFromChildren(context),
      ),
    );
  }
}
