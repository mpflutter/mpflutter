part of '../mpcore.dart';

MPElement _encodeOverlay(Element scaffoldElement) {
  Element? bodyElement;
  Color? bodyBackgroundColor;
  bool? barrierDismissible;
  if (scaffoldElement.widget is MPOverlayScaffold) {
    final widgetState =
        (scaffoldElement as StatefulElement).state as MPScaffoldState;
    bodyElement = widgetState.bodyKey.currentContext as Element?;
    bodyBackgroundColor =
        (scaffoldElement.widget as MPOverlayScaffold).backgroundColor;
    barrierDismissible =
        (scaffoldElement.widget as MPOverlayScaffold).barrierDismissible;
  }
  return MPElement(
    hashCode: scaffoldElement.hashCode,
    flutterElement: scaffoldElement,
    name: 'overlay',
    children: bodyElement != null
        ? MPElement.childrenFromFlutterElement(bodyElement)
        : null,
    attributes: {
      'barrierDismissible': barrierDismissible,
      'backgroundColor': bodyBackgroundColor != null
          ? bodyBackgroundColor.value.toString()
          : null,
      'onBackgroundTap': scaffoldElement.hashCode,
    },
  );
}
