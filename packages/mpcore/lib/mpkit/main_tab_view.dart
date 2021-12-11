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

  int get currentPage {
    final state = _state;
    if (state == null) return 0;
    return state.currentPage;
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

class MPMainTabView extends StatefulWidget {
  final List<MPMainTabItem> tabs;
  final WidgetBuilder? loadingBuilder;
  final Widget Function(BuildContext, int)? tabBarBuilder;
  final MPMainTabController? controller;

  MPMainTabView({
    required this.tabs,
    this.loadingBuilder,
    this.tabBarBuilder,
    this.controller,
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

  Widget renderTabBar(BuildContext context) {
    if (widget.tabBarBuilder != null) {
      return widget.tabBarBuilder!(context, currentPage);
    }
    return Container(
      height: 48,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: widget.tabs
            .asMap()
            .map((k, v) {
              final child =
                  k == currentPage ? v.activeTabWidget : v.inactiveTabWidget;
              final handler = GestureDetector(
                onTap: () async {
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
      color: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return MPScaffold(body: widget.loadingBuilder?.call(context));
    }
    return widget.tabs[currentPage].builder(context);
  }
}
