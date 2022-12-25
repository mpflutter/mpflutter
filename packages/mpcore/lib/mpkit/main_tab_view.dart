part of 'mpkit.dart';

class MPMainTabItem {
  final Widget activeTabWidget;
  final Widget inactiveTabWidget;
  final WidgetBuilder builder;

  MPMainTabItem({
    required this.activeTabWidget,
    required this.inactiveTabWidget,
    required this.builder,
  });
}

class MPMainTabController extends ChangeNotifier {
  MPMainTabViewState? _state;
  final Future<bool> Function(int)? _canJump;

  MPMainTabController({Future<bool> Function(int)? canJump})
      : _canJump = canJump;

  int get currentPage {
    final state = _state;
    if (state == null) return 0;
    return state.currentPage;
  }

  Future<bool> canJump(int page) async {
    return await _canJump?.call(page) ?? true;
  }

  void jumpToPage(int page) async {
    final state = _state;
    if (state == null) return;
    // ignore: invalid_use_of_protected_member
    state.setState(() {
      state.currentPage = page;
      state.loading = true;
    });
    await Future.delayed(Duration(milliseconds: 100));
    // ignore: invalid_use_of_protected_member
    state.setState(() {
      state.loading = false;
    });
  }
}

enum MPMainTabLocation {
  top,
  bottom,
}

class MPMainTabView extends StatefulWidget {
  final MPMainTabLocation tabLocation;
  final List<MPMainTabItem> tabs;
  final WidgetBuilder? loadingBuilder;
  final double tabBarHeight;
  final Color tabBarColor;
  final Widget Function(BuildContext, int)? tabBarBuilder;
  final MPMainTabController? controller;
  final bool keepAlive;

  MPMainTabView({
    required this.tabs,
    this.tabLocation = MPMainTabLocation.bottom,
    this.loadingBuilder,
    this.tabBarHeight = 48,
    this.tabBarColor = Colors.white,
    this.tabBarBuilder,
    this.controller,
    this.keepAlive = false,
  }) {
    assert(tabs.isNotEmpty);
  }

  @override
  State<MPMainTabView> createState() => MPMainTabViewState();
}

class MPMainTabViewState extends State<MPMainTabView> {
  int currentPage = 0;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    widget.controller?._state = this;
  }

  @override
  void didUpdateWidget(covariant MPMainTabView oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget.controller?._state = null;
    widget.controller?._state = this;
  }

  PreferredSizeWidget renderTabBar(BuildContext context) {
    if (widget.tabBarBuilder != null) {
      return _TabBar(
        widget.tabBarHeight,
        widget.tabBarBuilder!(context, currentPage),
        widget.tabBarColor,
      );
    }
    return _TabBar(
      widget.tabBarHeight,
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: widget.tabs
            .asMap()
            .map((k, v) {
              final child =
                  k == currentPage ? v.activeTabWidget : v.inactiveTabWidget;
              final handler = GestureDetector(
                onTap: () async {
                  if (widget.controller != null) {
                    if (await widget.controller!.canJump(k) != true) {
                      return;
                    }
                  }
                  setState(() {
                    currentPage = k;
                    loading = true;
                  });
                  await Future.delayed(Duration(milliseconds: 100));
                  setState(() {
                    loading = false;
                  });
                },
                child: child,
              );
              return MapEntry(k, handler);
            })
            .values
            .toList(),
      ),
      widget.tabBarColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.keepAlive && loading) {
      return MPScaffold(body: widget.loadingBuilder?.call(context));
    }
    if (widget.keepAlive) {
      return Stack(
          children: widget.tabs
              .asMap()
              .map((key, value) {
                return MapEntry(
                    key,
                    _IsTabActive(
                      actived: key == currentPage,
                      child: Positioned.fill(
                        child: value.builder(context),
                      ),
                    ));
              })
              .values
              .toList());
    } else {
      return widget.tabs[currentPage].builder(context);
    }
  }
}

class _TabBar extends StatelessWidget implements PreferredSizeWidget {
  final double height;
  final Widget child;
  final Color tabBarColor;

  _TabBar(this.height, this.child, this.tabBarColor);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      child: child,
      color: tabBarColor,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}

class _IsTabActive extends StatelessWidget {
  final Widget child;
  final bool actived;

  _IsTabActive({required this.actived, required this.child});

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
