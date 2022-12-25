part of 'mpkit.dart';

class MPAppBarPinned extends StatelessWidget implements PreferredSizeWidget {
  final Widget? headerContent;
  final Widget appBarContent;
  final double appBarHeight;
  final Widget? footerContent;

  const MPAppBarPinned({
    this.headerContent,
    required this.appBarContent,
    required this.appBarHeight,
    this.footerContent,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        headerContent ?? Container(),
        appBarContent,
        footerContent ?? Container(),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(appBarHeight);
}
