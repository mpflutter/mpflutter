part of 'mpkit.dart';

final List<MPScaffoldState> scaffoldStates = [];
final Map<int, MPScaffoldState> routeScaffoldStateMap = {};

class MPWechatMiniProgramShareInfo {
  final String? title;
  final String? routeName;
  final Map? routeParams;
  final String? customPath;
  final String? imageUrl;

  const MPWechatMiniProgramShareInfo({
    this.title,
    this.routeName,
    this.routeParams,
    this.customPath,
    this.imageUrl,
  });
}

class MPWechatMiniProgramShareTimeline {
  final String? title;
  final String? routeName;
  final Map? routeParams;
  final String? customPath;
  final String? imageUrl;

  const MPWechatMiniProgramShareTimeline({
    this.title,
    this.routeName,
    this.routeParams,
    this.customPath,
    this.imageUrl,
  });
}

class MPWechatMiniProgramAddToFavorites {
  final String? title;
  final String? routeName;
  final Map? routeParams;
  final String? customPath;
  final String? imageUrl;

  const MPWechatMiniProgramAddToFavorites({
    this.title,
    this.routeName,
    this.routeParams,
    this.customPath,
    this.imageUrl,
  });
}

class MPWechatMiniProgramShareRequest {
  final String? from;
  final String? webViewUrl;

  const MPWechatMiniProgramShareRequest({this.from, this.webViewUrl});
}

class MPScaffold extends StatefulWidget {
  final String? name;
  final Color? appBarColor;
  final Color? appBarTintColor;
  final Widget? body;
  final Function? onRefresh;
  final Function(double)? onPageScroll;
  final Future<MPWechatMiniProgramShareInfo> Function(
    MPWechatMiniProgramShareRequest request,
  )? onWechatMiniProgramShareAppMessage;
  final MPWechatMiniProgramShareTimeline Function()?
      onWechatMiniProgramShareTimeline;
  final MPWechatMiniProgramAddToFavorites Function()?
      onWechatMiniProgramAddToFavorites;
  final Function? onReachBottom;
  final PreferredSizeWidget? appBar;
  final Widget? bottomBar;
  final bool? bottomBarWithSafeArea;
  final Color? bottomBarSafeAreaColor;
  final Widget? floatingBody;
  final Color? backgroundColor;

  const MPScaffold({
    this.name,
    this.appBarColor,
    this.appBarTintColor,
    this.body,
    this.onRefresh,
    this.onPageScroll,
    this.onWechatMiniProgramShareAppMessage,
    this.onWechatMiniProgramShareTimeline,
    this.onWechatMiniProgramAddToFavorites,
    this.onReachBottom,
    this.appBar,
    this.bottomBar,
    this.bottomBarWithSafeArea,
    this.bottomBarSafeAreaColor,
    this.floatingBody,
    this.backgroundColor,
  });

  @override
  MPScaffoldState createState() => MPScaffoldState();
}

class MPScaffoldState extends State<MPScaffold> {
  final bodyKey = GlobalKey();
  final appBarKey = GlobalKey();
  final bottomBarKey = GlobalKey();
  final floatingBodyKey = GlobalKey();
  bool hasRootScroller = false;

  @override
  void dispose() {
    scaffoldStates.remove(this);
    routeScaffoldStateMap.removeWhere((key, value) => value == this);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    scaffoldStates.add(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null) {
      routeScaffoldStateMap[route.hashCode] = this;
    }
  }

  bool isInInactiveTab() {
    if (context.findAncestorWidgetOfExactType<_IsTabActive>()?.actived ==
        false) {
      return true;
    }
    return false;
  }

  void refreshState() {
    setState(() {});
  }

  bool isBottomBarWithSafeArea() {
    final mainTabBar = context
        .findAncestorStateOfType<MPMainTabViewState>()
        ?.renderTabBar(context);
    if (mainTabBar != null) {
      return true;
    }
    return widget.bottomBarWithSafeArea ?? false;
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).size.width < 10 ||
        MediaQuery.of(context).size.height < 10) {
      return Container();
    }
    final mainTabBar = context
        .findAncestorStateOfType<MPMainTabViewState>()
        ?.renderTabBar(context);
    final mainTabViewWidget =
        context.findAncestorWidgetOfExactType<MPMainTabView>();
    Widget child = Stack(
      children: [
        Positioned.fill(
          child: Column(
            key: Key('__ScaffoldStack'),
            children: [
              (() {
                if (mainTabBar != null &&
                    mainTabViewWidget?.tabLocation == MPMainTabLocation.top) {
                  return MPScaffoldAppBar(
                    key: appBarKey,
                    child: mainTabBar,
                  );
                } else if (widget.appBar != null) {
                  return MPScaffoldAppBar(
                    key: appBarKey,
                    child: widget.appBar,
                  );
                }
                return Container();
              })(),
              widget.body != null
                  ? Expanded(
                      child: MPScaffoldBody(
                        key: bodyKey,
                        child: Container(
                          color: widget.backgroundColor,
                          child: widget.body,
                        ),
                        appBarHeight: widget.appBar != null
                            ? widget.appBar?.preferredSize.height
                            : null,
                      ),
                    )
                  : Expanded(child: Container()),
              (() {
                if (mainTabBar != null &&
                    mainTabViewWidget?.tabLocation ==
                        MPMainTabLocation.bottom) {
                  return MPScaffoldBottomBar(
                    key: bottomBarKey,
                    child: mainTabBar,
                  );
                } else if (widget.bottomBar != null) {
                  return MPScaffoldBottomBar(
                    key: bottomBarKey,
                    child: widget.bottomBar,
                  );
                }
                return Container();
              })(),
            ],
          ),
        ),
        widget.floatingBody != null
            ? MPScaffoldFloatingBody(
                key: floatingBodyKey, child: widget.floatingBody)
            : Container(),
      ],
    );
    final app = context.findAncestorWidgetOfExactType<MPApp>();
    var mediaQuery = MediaQuery.of(context);
    final route = ModalRoute.of(context);
    if (route != null) {
      final routeArguments = ModalRoute.of(context)?.settings.arguments;
      if (routeArguments is Map &&
          routeArguments.containsKey('\$viewportWidth') &&
          routeArguments.containsKey('\$viewportHeight')) {
        mediaQuery = mediaQuery.copyWith(
          size: Size(
            (routeArguments['\$viewportWidth'] as num).toDouble(),
            (routeArguments['\$viewportHeight'] as num).toDouble(),
          ),
        );
      } else {
        final routeViewport =
            MPNavigatorObserver.instance.routeViewport[route.hashCode];
        if (routeViewport != null) {
          mediaQuery = mediaQuery.copyWith(size: routeViewport);
        }
      }
    }
    if (app != null && app.maxWidth != null) {
      if (mediaQuery.size.width > app.maxWidth!) {
        mediaQuery = mediaQuery.copyWith(
          size: Size(app.maxWidth!, mediaQuery.size.height),
        );
      }
    }
    child = MediaQuery(
      data: mediaQuery,
      child: child,
    );
    child = Align(
      alignment: Alignment.topLeft,
      child: Container(
        width: mediaQuery.size.width,
        height: mediaQuery.size.height,
        child: child,
      ),
    );
    return child;
  }
}

class MPOverlayScaffold extends MPScaffold {
  final bool? barrierDismissible;
  final Function? onBackgroundTap;
  final ModalRoute? parentRoute;

  const MPOverlayScaffold({
    Widget? body,
    Color? backgroundColor,
    this.barrierDismissible,
    this.onBackgroundTap,
    this.parentRoute,
  }) : super(body: body, backgroundColor: backgroundColor);
}

class MPScaffoldBody extends StatelessWidget {
  final Widget? child;
  final double? appBarHeight;

  const MPScaffoldBody({
    Key? key,
    this.child,
    this.appBarHeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return child ?? Container();
  }
}

class MPScaffoldAppBar extends StatelessWidget {
  final PreferredSizeWidget? child;

  const MPScaffoldAppBar({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (child == null) {
      return Container();
    }
    return Container(
      constraints:
          BoxConstraints.tightFor(width: MediaQuery.of(context).size.width),
      child: child,
    );
  }
}

class MPScaffoldBottomBar extends StatelessWidget {
  final Widget? child;

  const MPScaffoldBottomBar({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (child == null) {
      return Container();
    }
    return Container(
      constraints:
          BoxConstraints.tightFor(width: MediaQuery.of(context).size.width),
      child: child,
    );
  }
}

class MPScaffoldFloatingBody extends StatelessWidget {
  final Widget? child;

  const MPScaffoldFloatingBody({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return child ?? Container();
  }
}
