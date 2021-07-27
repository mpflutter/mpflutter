import 'dart:math';

import 'package:flutter/widgets.dart';

import 'mpkit.dart';

Future<T> showMPDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
  Color? barrierColor,
}) async {
  final parentRoute = ModalRoute.of(context);
  final result = await Navigator.of(context).push(MPPageRoute(
    builder: (context) {
      return MPOverlayScaffold(
        backgroundColor: barrierColor,
        onBackgroundTap: () {
          if (barrierDismissible) {
            Navigator.of(context).pop();
          }
        },
        body: builder(context),
        parentRoute: parentRoute,
      );
    },
    settings: RouteSettings(name: '/mp_dialog/${Random().nextDouble()}'),
  ));
  return result;
}
