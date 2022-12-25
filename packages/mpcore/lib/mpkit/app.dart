part of 'mpkit.dart';

class MPApp extends StatelessWidget {
  @override
  final Key? key;
  final String? title;
  final Color? color;
  final Map<String, WidgetBuilder> routes;
  final RouteFactory? onGenerateRoute;
  final List<NavigatorObserver> navigatorObservers;
  final double? maxWidth;
  final GlobalKey<NavigatorState>? navigatorKey;
  final PageRouteFactory? pageRouteBuilder;

  const MPApp({
    this.key,
    this.title,
    this.color,
    required this.routes,
    this.onGenerateRoute,
    required this.navigatorObservers,
    this.maxWidth,
    this.navigatorKey,
    this.pageRouteBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return WidgetsApp(
      key: key,
      title: title ?? '',
      color: color ?? Colors.blue,
      navigatorKey: navigatorKey,
      builder: (context, widget) {
        return widget ?? Container();
      },
      routes: routes,
      navigatorObservers: navigatorObservers,
      pageRouteBuilder: <T>(RouteSettings settings, WidgetBuilder builder) {
        if (pageRouteBuilder != null) {
          return pageRouteBuilder!.call(settings, builder);
        }
        return MPPageRoute<T>(
          settings: settings,
          builder: (context) => SplashScreen(null, builder),
        );
      },
      onGenerateRoute: (settings) {
        return onGenerateRoute?.call(settings) ??
            MPPageRoute(builder: (context) {
              final routeBuilder = routes[settings.name];
              if (routeBuilder != null) {
                return routeBuilder(context);
              } else {
                return Container();
              }
            });
      },
      onGenerateInitialRoutes: (_) {
        final routeName = MPNavigatorObserver.instance.initialRoute;
        final routeParams = MPNavigatorObserver.instance.initialParams;
        final routeSetting =
            RouteSettings(name: routeName, arguments: routeParams);
        return [
          onGenerateRoute?.call(routeSetting) ??
              MPPageRoute(
                builder: (context) {
                  final routeBuilder = routes[routeName];
                  if (routeBuilder != null) {
                    return SplashScreen(routeBuilder(context), null);
                  } else {
                    return Container();
                  }
                },
                settings: routeSetting,
              )
        ];
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  final Widget? home;
  final WidgetBuilder? homeBuilder;

  SplashScreen(this.home, this.homeBuilder);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool finished = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 50)).then((_) {
      setState(() {
        finished = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (finished) {
      if (widget.home != null) {
        return widget.home!;
      } else if (widget.homeBuilder != null) {
        return widget.homeBuilder!.call(context);
      }
    }
    return MPScaffold(backgroundColor: Colors.white);
  }
}
