part of '../../mp_flutter_runtime.dart';

class _CustomScrollView extends ComponentView {
  _CustomScrollView({
    Key? key,
    Map? data,
    Map? parentData,
    required _MPComponentFactory componentFactory,
  }) : super(
            key: key,
            data: data,
            parentData: parentData,
            componentFactory: componentFactory);

  @override
  Widget builder(BuildContext context) {
    final scrollDirection = (() {
      if (getStringFromAttributes(context, 'scrollDirection') ==
          'Axis.horizontal') {
        return Axis.horizontal;
      } else {
        return Axis.vertical;
      }
    })();
    final childrenWidget = getWidgetsFromChildren(context);
    if (childrenWidget == null) {
      return const SizedBox();
    }
    final controller = _ScrollControllerManager.createController(dataHashCode);
    final onScrollAttribute = getIntFromAttributes(context, 'onScroll');
    if (onScrollAttribute != null) {
      if (!controller.hasListeners) {
        controller.addListener(() {
          getEngine(context)?._sendMessage({
            "type": "scroll_view",
            "message": {
              "event": "onScroll",
              "target": onScrollAttribute,
              "scrollLeft": scrollDirection == Axis.vertical
                  ? 0
                  : controller.position.pixels,
              "scrollTop": scrollDirection == Axis.horizontal
                  ? 0
                  : controller.position.pixels,
              "viewportDimension": controller.position.viewportDimension,
              "scrollHeight": controller.position.maxScrollExtent,
            },
          });
        });
      }
    }
    final isRoot = getBoolFromAttributes(context, 'isRoot') ?? false;
    Widget widget = CustomScrollView(
      scrollDirection: scrollDirection,
      controller: controller,
      slivers: childrenWidget.map((e) {
        if (e is _SliverList ||
            e is _SliverGrid ||
            e is _SliverPersistentHeader) {
          return e;
        } else {
          return SliverToBoxAdapter(child: e);
        }
      }).toList(),
    );
    final onRefreshAttribute = getIntFromAttributes(context, 'onRefresh');
    if (onRefreshAttribute != null) {
      widget = RefreshIndicator(
          child: widget,
          onRefresh: () async {
            getEngine(context)?._sendMessage({
              "type": "scroll_view",
              "message": {
                "event": "onRefresh",
                "target": onRefreshAttribute,
                "isRoot": isRoot,
              },
            });
            final completer = _RefresherManager.createCompleter(dataHashCode);
            await completer.future;
          });
    }
    if (isRoot) {
      widget = NotificationListener<ScrollNotification>(
        onNotification: (details) {
          final mpPage = context.findAncestorStateOfType<_MPPageState>();
          if (mpPage != null) {
            if (details.metrics.atEdge && details.metrics.pixels > 0) {
              mpPage.onReachBottom();
            }
            mpPage.onPageScroll(details.metrics.pixels);
          }
          return true;
        },
        child: widget,
      );
    }
    return widget;
  }
}

class _SliverList extends ComponentView {
  _SliverList({
    Key? key,
    Map? data,
    Map? parentData,
    required _MPComponentFactory componentFactory,
  }) : super(
            key: key,
            data: data,
            parentData: parentData,
            componentFactory: componentFactory,
            noLayout: true);

  @override
  Widget builder(BuildContext context) {
    final childrenWidget = getWidgetsFromChildren(context);
    Widget child = SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return childrenWidget![index];
        },
        childCount: childrenWidget?.length ?? 0,
      ),
    );
    final padding = getEdgeInsetsFromAttributes(context, 'padding');
    if (padding != null) {
      child = SliverPadding(padding: padding, sliver: child);
    }
    return child;
  }
}

class _SliverGrid extends ComponentView {
  _SliverGrid({
    Key? key,
    Map? data,
    Map? parentData,
    required _MPComponentFactory componentFactory,
  }) : super(
            key: key,
            data: data,
            parentData: parentData,
            componentFactory: componentFactory,
            noLayout: true);

  @override
  Widget builder(BuildContext context) {
    final gridDelegate = getValueFromAttributes(context, 'gridDelegate');
    final childrenWidget = getWidgetsFromChildren(context);
    Widget? child;
    if (gridDelegate is Map) {
      String classname = gridDelegate['classname'];
      if (classname == 'SliverGridDelegateWithFixedCrossAxisCount') {
        child = SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            mainAxisSpacing:
                _Utils.toDouble(gridDelegate['mainAxisSpacing'], 0),
            crossAxisSpacing:
                _Utils.toDouble(gridDelegate['crossAxisSpacing'], 0),
            crossAxisCount: _Utils.toInt(gridDelegate['crossAxisCount'], 1),
            childAspectRatio:
                _Utils.toDouble(gridDelegate['childAspectRatio'], 1.0),
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return childrenWidget![index];
            },
            childCount: childrenWidget?.length ?? 0,
          ),
        );
      } else if (classname == 'SliverGridDelegateWithMaxCrossAxisExtent') {
        child = SliverGrid(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              mainAxisSpacing:
                  _Utils.toDouble(gridDelegate['mainAxisSpacing'], 0),
              crossAxisSpacing:
                  _Utils.toDouble(gridDelegate['crossAxisSpacing'], 0),
              maxCrossAxisExtent:
                  _Utils.toDouble(gridDelegate['maxCrossAxisExtent'], 0),
              childAspectRatio:
                  _Utils.toDouble(gridDelegate['childAspectRatio'], 1),
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return childrenWidget![index];
              },
              childCount: _Utils.toInt(childrenWidget?.length, 0),
            ));
      } else if (classname == 'SliverWaterfallDelegate') {
        child = SliverWaterfallFlow(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return childrenWidget![index];
            },
            childCount: _Utils.toInt(childrenWidget?.length, 0),
          ),
          gridDelegate: SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
            mainAxisSpacing:
                _Utils.toDouble(gridDelegate['mainAxisSpacing'], 0),
            crossAxisSpacing:
                _Utils.toDouble(gridDelegate['crossAxisSpacing'], 0),
            crossAxisCount: _Utils.toInt(gridDelegate['crossAxisCount'], 1),
          ),
        );
      }
    }
    final padding = getEdgeInsetsFromAttributes(context, 'padding');
    if (padding != null) {
      child = SliverPadding(padding: padding, sliver: child);
    }
    return child ?? const SliverToBoxAdapter(child: SizedBox());
  }
}

class _SliverPersistentHeader extends ComponentView {
  _SliverPersistentHeader({
    Key? key,
    Map? data,
    Map? parentData,
    required _MPComponentFactory componentFactory,
  }) : super(
            key: key,
            data: data,
            parentData: parentData,
            componentFactory: componentFactory,
            noLayout: true);

  @override
  Widget builder(BuildContext context) {
    final child = getWidgetFromChildren(context);
    double height = 0;
    if (child is ComponentView) {
      height = child.getSize().height;
    }
    return SliverPersistentHeader(
      delegate: _SliverPersistentHeaderDelegate(
        child ?? const SizedBox(),
        height,
      ),
      pinned: getBoolFromAttributes(context, 'pinned') ?? false,
    );
  }
}

class _SliverPersistentHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  _SliverPersistentHeaderDelegate(this.child, this.height);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
