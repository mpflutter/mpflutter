part of '../../mp_flutter_runtime.dart';

class _GridView extends ComponentView {
  _GridView({
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
    final gridDelegate = getValueFromAttributes(context, 'gridDelegate');
    final childrenWidget = getWidgetsFromChildren(context);
    if (childrenWidget == null) {
      return const SizedBox();
    }
    final isRoot = getBoolFromAttributes(context, 'isRoot') ?? false;
    Widget widget = const SizedBox();
    if (gridDelegate is Map) {
      String classname = gridDelegate['classname'];
      if (classname == 'SliverGridDelegateWithFixedCrossAxisCount') {
        widget = GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            mainAxisSpacing:
                _Utils.toDouble(gridDelegate['mainAxisSpacing'], 0.0),
            crossAxisSpacing:
                _Utils.toDouble(gridDelegate['crossAxisSpacing'], 0),
            crossAxisCount: _Utils.toInt(gridDelegate['crossAxisCount'], 1),
            childAspectRatio:
                _Utils.toDouble(gridDelegate['childAspectRatio'], 0),
          ),
          scrollDirection: scrollDirection,
          padding: getEdgeInsetsFromAttributes(context, 'padding'),
          itemBuilder: (context, index) {
            return childrenWidget[index];
          },
          itemCount: childrenWidget.length,
          controller: controller,
        );
      } else if (classname == 'SliverGridDelegateWithMaxCrossAxisExtent') {
        widget = GridView.builder(
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            mainAxisSpacing: _Utils.toDouble(gridDelegate['mainAxisSpacing']),
            crossAxisSpacing:
                _Utils.toDouble(gridDelegate['crossAxisSpacing'], 0),
            maxCrossAxisExtent:
                _Utils.toDouble(gridDelegate['maxCrossAxisExtent'], 0.0),
            childAspectRatio:
                _Utils.toDouble(gridDelegate['childAspectRatio'], 1.0),
          ),
          scrollDirection: scrollDirection,
          padding: getEdgeInsetsFromAttributes(context, 'padding'),
          itemBuilder: (context, index) {
            return childrenWidget[index];
          },
          itemCount: childrenWidget.length,
          controller: controller,
        );
      } else if (classname == 'SliverWaterfallDelegate') {
        widget = WaterfallFlow.builder(
          gridDelegate: SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
            mainAxisSpacing:
                _Utils.toDouble(gridDelegate['mainAxisSpacing'], 0.0),
            crossAxisSpacing:
                _Utils.toDouble(gridDelegate['crossAxisSpacing'], 0.0),
            crossAxisCount: _Utils.toInt(gridDelegate['crossAxisCount'], 0),
          ),
          scrollDirection: scrollDirection,
          padding: getEdgeInsetsFromAttributes(context, 'padding'),
          itemBuilder: (context, index) {
            return childrenWidget[index];
          },
          itemCount: childrenWidget.length,
          controller: controller,
        );
      }
    }
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
