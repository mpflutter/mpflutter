part of '../../mp_flutter_runtime.dart';

class _ListView extends ComponentView {
  _ListView({
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
    final childrenWidget = getWidgetsFromChildren(context);
    if (childrenWidget == null) {
      return const SizedBox();
    }
    final isRoot = getBoolFromAttributes(context, 'isRoot') ?? false;
    Widget widget = ListView.builder(
      scrollDirection: (() {
        if (getStringFromAttributes(context, 'scrollDirection') ==
            'Axis.horizontal') {
          return Axis.horizontal;
        } else {
          return Axis.vertical;
        }
      })(),
      padding: getEdgeInsetsFromAttributes(context, 'padding'),
      itemBuilder: (context, index) {
        return childrenWidget[index];
      },
      itemCount: childrenWidget.length,
    );
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
