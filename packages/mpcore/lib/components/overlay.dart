part of '../mpcore.dart';

MPElement _encodeOverlay(Element scaffoldElement) {
  Element? bodyElement;
  Color? bodyBackgroundColor;
  if (scaffoldElement.widget is MPOverlayScaffold) {
    final widgetState =
        (scaffoldElement as StatefulElement).state as MPScaffoldState;
    bodyElement = widgetState.bodyKey.currentContext as Element?;
    bodyBackgroundColor =
        (scaffoldElement.widget as MPOverlayScaffold).backgroundColor;
  }
  return MPElement(
    hashCode: scaffoldElement.hashCode,
    flutterElement: scaffoldElement,
    name: 'overlay',
    children: bodyElement != null
        ? MPElement.childrenFromFlutterElement(bodyElement)
        : null,
    attributes: {
      'backgroundColor': bodyBackgroundColor != null
          ? bodyBackgroundColor.value.toString()
          : null,
      'onBackgroundTap': scaffoldElement.hashCode,
    },
  );
}
