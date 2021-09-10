part of 'mpkit.dart';

Future<T> showMPDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
  Color? barrierColor,
}) async {
  final parentRoute = ModalRoute.of(context);
  final result = await Navigator.of(context).push(MPPageRoute(
    builder: (childContext) {
      return MediaQuery(
        data: MediaQuery.of(context),
        child: Builder(builder: (context) {
          return MPOverlayScaffold(
            backgroundColor: barrierColor,
            onBackgroundTap: () {
              if (barrierDismissible) {
                Navigator.of(context).pop();
              }
            },
            body: builder(childContext),
            parentRoute: parentRoute,
          );
        }),
      );
    },
    settings: RouteSettings(name: '/mp_dialog/${math.Random().nextDouble()}'),
  ));
  return result;
}
