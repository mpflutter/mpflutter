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

  MPApp({
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
      color: color ?? Color(0),
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
        return MPPageRoute<T>(settings: settings, builder: builder);
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
                    return routeBuilder(context);
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
