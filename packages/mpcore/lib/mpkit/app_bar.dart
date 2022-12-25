part of 'mpkit.dart';

class MPAppBar extends StatelessWidget implements PreferredSizeWidget {
  final BuildContext context;
  final Widget? leading;
  final Widget? title;
  final Widget? trailing;
  final Color backgroundColor;
  final double appBarHeight;
  final bool primary;

  const MPAppBar({
    required this.context,
    this.leading,
    this.title,
    this.trailing,
    this.backgroundColor = Colors.white,
    this.appBarHeight = 44,
    this.primary = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: appBarHeight + (primary ? MediaQuery.of(context).padding.top : 0),
      color: backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: primary ? MediaQuery.of(context).padding.top : 0.0,
            width: MediaQuery.of(context).size.width,
          ),
          Container(
            height: appBarHeight,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Center(
                    child: DefaultTextStyle(
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                      child: title ?? Container(),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: _renderLeading(context),
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: _renderTrailing(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _renderLeading(BuildContext context) {
    if (leading != null) {
      return leading!;
    } else {
      if (Navigator.of(context).canPop()) {
        return GestureDetector(
          onTap: () async {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
          child: renderBackButton(),
        );
      }
      return SizedBox();
    }
  }

  Container renderBackButton() {
    return Container(
      width: 44,
      height: 44,
      child: Center(
        child: Container(
          width: 18,
          height: 18,
          child: Image.network(
            'https://dist.mpflutter.com/res/arrow_back_ios_new_black_24dp.svg',
            width: 18,
            height: 18,
          ),
        ),
      ),
    );
  }

  Widget _renderTrailing(BuildContext context) {
    if (trailing != null) {
      return trailing!;
    } else {
      return Container();
    }
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(appBarHeight + MediaQuery.of(context).padding.top);
}
