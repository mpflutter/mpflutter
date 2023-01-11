part of './mpkit_encoder.dart';

MPElement _encodeMPScaffold(Element element) {
  final stackedScaffold =
      element.findAncestorWidgetOfExactType<MPScaffold>() != null;
  final widget = element.widget as MPScaffold;
  final widgetState = (element as StatefulElement).state as MPScaffoldState;
  widgetState.hasRootScroller = false;
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
  final mainTabView = element.findAncestorWidgetOfExactType<MPMainTabView>();
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
      'bottomBarWithSafeArea': mainTabView != null &&
              mainTabView.tabLocation == MPMainTabLocation.bottom
          ? true
          : widget.bottomBarWithSafeArea,
      'bottomBarSafeAreaColor': mainTabView != null &&
              mainTabView.tabLocation == MPMainTabLocation.bottom
          ? mainTabView.tabBarColor.value.toString()
          : widget.bottomBarSafeAreaColor?.value.toString(),
      'backgroundColor': bodyBackgroundColor != null
          ? bodyBackgroundColor.value.toString()
          : null,
      'hasRootScroller': widgetState.hasRootScroller,
      'wechatMiniProgramShareTimeline': (() {
        final onWechatMiniProgramShareTimeline =
            widget.onWechatMiniProgramShareTimeline;
        if (onWechatMiniProgramShareTimeline == null) {
          return null;
        }
        final shareInfo = onWechatMiniProgramShareTimeline.call();
        final routeName = shareInfo.routeName ??
            ModalRoute.of(widgetState.context)?.settings.name ??
            '/';
        final routeParams = shareInfo.routeParams ??
            ModalRoute.of(widgetState.context)?.settings.arguments;
        final result = <String, dynamic>{
          'title': shareInfo.title ?? widget.name,
          'query': (() {
            if (shareInfo.customPath != null) {
              return shareInfo.customPath;
            } else {
              return 'route=${routeName}&${(() {
                if (routeParams is Map) {
                  return routeParams
                      .map((key, value) {
                        return MapEntry(
                          key,
                          '$key=${value is String ? Uri.encodeQueryComponent(value) : ""}',
                        );
                      })
                      .values
                      .join('&');
                }
                return '';
              })()}';
            }
          })(),
          'imageUrl': shareInfo.imageUrl,
        };
        return result;
      })(),
      'wechatMiniProgramAddToFavorites': (() {
        final onWechatMiniProgramAddToFavorites =
            widget.onWechatMiniProgramAddToFavorites;
        if (onWechatMiniProgramAddToFavorites == null) {
          return null;
        }
        final shareInfo = onWechatMiniProgramAddToFavorites.call();
        final routeName = shareInfo.routeName ??
            ModalRoute.of(widgetState.context)?.settings.name ??
            '/';
        final routeParams = shareInfo.routeParams ??
            ModalRoute.of(widgetState.context)?.settings.arguments;
        final result = <String, dynamic>{
          'title': shareInfo.title ?? widget.name,
          'query': (() {
            if (shareInfo.customPath != null) {
              return shareInfo.customPath;
            } else {
              return 'route=${routeName}&${(() {
                if (routeParams is Map) {
                  return routeParams
                      .map((key, value) {
                        return MapEntry(
                          key,
                          '$key=${value is String ? Uri.encodeQueryComponent(value) : ""}',
                        );
                      })
                      .values
                      .join('&');
                }
                return '';
              })()}';
            }
          })(),
          'imageUrl': shareInfo.imageUrl,
        };
        return result;
      })(),
    },
  );
}
