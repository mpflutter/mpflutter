part of 'mpkit.dart';

class MPPageRoute<T> extends PageRoute<T> {
  final WidgetBuilder builder;

  MPPageRoute({RouteSettings? settings, required this.builder})
      : super(settings: settings);

  @override
  Color get barrierColor => Color(0);

  @override
  String get barrierLabel => '';

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return builder(context);
  }

  @override
  bool get maintainState => true;
}
