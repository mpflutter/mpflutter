part of '../../mp_flutter_runtime.dart';

class _CustomScrollView extends ComponentView {
  _CustomScrollView({
    Key? key,
    Map? data,
  }) : super(key: key, data: data);

  @override
  Widget builder(BuildContext context) {
    final childrenWidget = getWidgetsFromChildren(context);
    if (childrenWidget == null) {
      return const SizedBox();
    }
    return CustomScrollView(
      scrollDirection: (() {
        if (getStringFromAttributes(context, 'scrollDirection') ==
            'Axis.horizontal') {
          return Axis.horizontal;
        } else {
          return Axis.vertical;
        }
      })(),
      slivers: childrenWidget.map((e) {
        if (e is _SliverList || e is _SliverGrid) {
          return e;
        } else {
          return SliverToBoxAdapter(child: e);
        }
      }).toList(),
    );
  }
}

class _SliverList extends ComponentView {
  _SliverList({
    Key? key,
    Map? data,
  }) : super(key: key, data: data, noLayout: true);

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
  }) : super(key: key, data: data, noLayout: true);

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
            mainAxisSpacing: gridDelegate['mainAxisSpacing'] ?? 0,
            crossAxisSpacing: gridDelegate['crossAxisSpacing'] ?? 0,
            crossAxisCount: gridDelegate['crossAxisCount'] ?? 1,
            childAspectRatio: gridDelegate['childAspectRatio'] ?? 0,
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
              mainAxisSpacing: gridDelegate['mainAxisSpacing'] ?? 0,
              crossAxisSpacing: gridDelegate['crossAxisSpacing'] ?? 0,
              maxCrossAxisExtent: gridDelegate['maxCrossAxisExtent'] ?? 0,
              childAspectRatio: gridDelegate['childAspectRatio'] ?? 0,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return childrenWidget![index];
              },
              childCount: childrenWidget?.length ?? 0,
            ));
      } else if (classname == 'SliverWaterfallDelegate') {
        child = SliverWaterfallFlow(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return childrenWidget![index];
            },
            childCount: childrenWidget?.length ?? 0,
          ),
          gridDelegate: SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
            mainAxisSpacing: gridDelegate['mainAxisSpacing'] ?? 0,
            crossAxisSpacing: gridDelegate['crossAxisSpacing'] ?? 0,
            crossAxisCount: gridDelegate['crossAxisCount'] ?? 0,
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
