part of './mpkit_encoder.dart';

MPElement _encodeMPScaffold(Element element) {
  final stackedScaffold =
      element.findAncestorWidgetOfExactType<MPScaffold>() != null;
  final widget = element.widget as MPScaffold;
  final widgetState = (element as StatefulElement).state as MPScaffoldState;
  final name = widget.name;
  Element? headerElement;
  Element? tabBarElement;
  final appBarElement = widgetState.appBarKey.currentContext as Element?;
  var bodyElement = widgetState.bodyKey.currentContext as Element?;
  var bottomBarElement = widgetState.bottomBarKey.currentContext as Element?;
  final floatingBodyElement =
      widgetState.floatingBodyKey.currentContext as Element?;
  final bodyBackgroundColor = widget.backgroundColor;
  if (stackedScaffold && bodyElement != null) {
    return MPElement.fromFlutterElement(bodyElement);
  }
  final appBarPreferredSize =
      (appBarElement?.widget as MPScaffoldAppBar?)?.child?.preferredSize;
  return MPElement(
    hashCode: element.hashCode,
    flutterElement: element,
    name: 'mp_scaffold',
    attributes: {
      'name': name,
      'appBar': appBarElement != null
          ? MPElement.fromFlutterElement(appBarElement)
          : null,
      'appBarColor': widget.appBarColor != null
          ? widget.appBarColor!.value.toString()
          : null,
      'appBarTintColor': widget.appBarTintColor != null
          ? widget.appBarTintColor!.value.toString()
          : null,
      'appBarHeight': appBarPreferredSize?.height ?? 0.0,
      'header': headerElement != null
          ? MPElement.fromFlutterElement(headerElement)
          : null,
      'tabBar': tabBarElement != null
          ? MPElement.fromFlutterElement(tabBarElement)
          : null,
      'body': bodyElement != null
          ? MPElement.fromFlutterElement(bodyElement)
          : null,
      'onPageScroll': widget.onPageScroll != null ? element.hashCode : null,
      'floatingBody': floatingBodyElement != null
          ? MPElement.fromFlutterElement(floatingBodyElement)
          : null,
      'bottomBar': bottomBarElement != null
          ? MPElement.fromFlutterElement(bottomBarElement)
          : null,
      'bottomBarWithSafeArea': widget.bottomBarWithSafeArea,
      'bottomBarSafeAreaColor': widget.bottomBarSafeAreaColor?.value.toString(),
      'backgroundColor': bodyBackgroundColor != null
          ? bodyBackgroundColor.value.toString()
          : null,
    },
  );
}
