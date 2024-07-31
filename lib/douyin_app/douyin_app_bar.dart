import 'package:flutter/widgets.dart';
import 'package:mpflutter_core/mpjs/mpjs.dart' as mpjs;

class DouyinAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String? title;
  final Color? frontColor;
  final Color? backgroundColor;
  DouyinAppBar({this.title, this.frontColor, this.backgroundColor});

  @override
  State<DouyinAppBar> createState() => _DouyinAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(0);
}

class _DouyinAppBarState extends State<DouyinAppBar> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    updateAppBar();
  }

  void updateAppBar() {
    if (ModalRoute.of(context)?.isCurrent == true) {
      final titleOption = mpjs.JSObject("Object");
      titleOption["title"] = widget.title ?? '';
      (mpjs.context["tt"] as mpjs.JSObject).callMethod(
        'setNavigationBarTitle',
        [titleOption],
      );
      if (widget.frontColor != null && widget.backgroundColor != null) {
        final colorOption = mpjs.JSObject("Object");
        colorOption["frontColor"] = colorToHex(widget.frontColor!);
        colorOption["backgroundColor"] = colorToHex(widget.backgroundColor!);
        (mpjs.context["tt"] as mpjs.JSObject).callMethod(
          'setNavigationBarColor',
          [colorOption],
        );
      }
    }
  }

  String colorToHex(Color color) {
    return '#${color.red.toRadixString(16).padLeft(2, '0')}'
        '${color.green.toRadixString(16).padLeft(2, '0')}'
        '${color.blue.toRadixString(16).padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    updateAppBar();
    return SizedBox();
  }
}
