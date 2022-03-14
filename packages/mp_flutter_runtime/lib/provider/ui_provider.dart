part of '../mp_flutter_runtime.dart';

class MPUIProvider {
  PreferredSizeWidget? createAppBar({
    required BuildContext context,
    String? title,
  }) {
    return AppBar(title: title != null ? Text(title) : null);
  }

  double? appBarHeight() {
    return kToolbarHeight;
  }

  bool isFullScreen() {
    return false;
  }

  Widget createCircularProgressIndicator({
    required BuildContext context,
    Color? color,
    double? size,
  }) {
    return SizedBox(
      width: size ?? 44.0,
      height: size ?? 44.0,
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation(color),
      ),
    );
  }
}
