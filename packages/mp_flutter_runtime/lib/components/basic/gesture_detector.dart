part of '../../mp_flutter_runtime.dart';

class _GestureDetector extends ComponentView {
  _GestureDetector({
    Key? key,
    Map? data,
    Map? parentData,
    required _MPComponentFactory componentFactory,
  }) : super(
          key: key,
          data: data,
          parentData: parentData,
          componentFactory: componentFactory,
        );

  @override
  Widget builder(BuildContext context) {
    final onTap = getIntFromAttributes(context, 'onTap');
    final onLongPress = getIntFromAttributes(context, 'onLongPress');
    final onLongPressStart = getIntFromAttributes(context, 'onLongPressStart');
    final onLongPressMoveUpdate =
        getIntFromAttributes(context, 'onLongPressMoveUpdate');
    final onLongPressEnd = getIntFromAttributes(context, 'onLongPressEnd');
    final onPanStart = getIntFromAttributes(context, 'onPanStart');
    final onPanUpdate = getIntFromAttributes(context, 'onPanUpdate');
    final onPanEnd = getIntFromAttributes(context, 'onPanEnd');
    return GestureDetector(
      onTap: onTap != null
          ? () {
              triggerEvent(context, 'onTap');
            }
          : null,
      onLongPress: onLongPress != null
          ? () {
              triggerEvent(context, 'onLongPress');
            }
          : null,
      onLongPressStart: onLongPressStart != null
          ? (detail) {
              triggerEvent(
                context,
                'onLongPressStart',
                globalPosition: detail.globalPosition,
                localPosition: detail.localPosition,
              );
            }
          : null,
      onLongPressMoveUpdate: onLongPressMoveUpdate != null
          ? (detail) {
              triggerEvent(
                context,
                'onLongPressMoveUpdate',
                globalPosition: detail.globalPosition,
                localPosition: detail.localPosition,
              );
            }
          : null,
      onLongPressEnd: onLongPressEnd != null
          ? (detail) {
              triggerEvent(
                context,
                'onLongPressEnd',
                globalPosition: detail.globalPosition,
                localPosition: detail.localPosition,
              );
            }
          : null,
      onPanStart: onPanStart != null
          ? (detail) {
              triggerEvent(
                context,
                'onPanStart',
                globalPosition: detail.globalPosition,
                localPosition: detail.localPosition,
              );
            }
          : null,
      onPanUpdate: onPanUpdate != null
          ? (detail) {
              triggerEvent(
                context,
                'onPanUpdate',
                globalPosition: detail.globalPosition,
                localPosition: detail.localPosition,
              );
            }
          : null,
      onPanEnd: onPanEnd != null
          ? (detail) {
              triggerEvent(
                context,
                'onPanEnd',
              );
            }
          : null,
      child: Container(
        color: Colors.transparent,
        child: getWidgetFromChildren(context),
      ),
    );
  }

  void triggerEvent(
    BuildContext context,
    String event, {
    Offset? globalPosition,
    Offset? localPosition,
  }) {
    final engine = getEngine(context);
    if (engine != null) {
      engine._sendMessage({
        "type": "gesture_detector",
        "message": {
          "event": event,
          "target": dataHashCode,
          "globalX": globalPosition?.dx,
          "globalY": globalPosition?.dy,
          "localX": localPosition?.dx,
          "localY": localPosition?.dy,
        },
      });
    }
  }
}
