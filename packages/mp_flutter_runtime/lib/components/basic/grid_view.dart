part of '../../mp_flutter_runtime.dart';

class _GridView extends ComponentView {
  _GridView({
    Key? key,
    Map? data,
  }) : super(key: key, data: data);

  @override
  Widget builder(BuildContext context) {
    final gridDelegate = getValueFromAttributes(context, 'gridDelegate');
    final childrenWidget = getWidgetsFromChildren(context);
    if (childrenWidget == null) {
      return const SizedBox();
    }
    if (gridDelegate is Map) {
      String classname = gridDelegate['classname'];
      if (classname == 'SliverGridDelegateWithFixedCrossAxisCount') {
        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            mainAxisSpacing: gridDelegate['mainAxisSpacing'] ?? 0,
            crossAxisSpacing: gridDelegate['crossAxisSpacing'] ?? 0,
            crossAxisCount: gridDelegate['crossAxisCount'] ?? 1,
            childAspectRatio: gridDelegate['childAspectRatio'] ?? 0,
          ),
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
      } else if (classname == 'SliverGridDelegateWithMaxCrossAxisExtent') {
        return GridView.builder(
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            mainAxisSpacing: gridDelegate['mainAxisSpacing'] ?? 0,
            crossAxisSpacing: gridDelegate['crossAxisSpacing'] ?? 0,
            maxCrossAxisExtent: gridDelegate['maxCrossAxisExtent'] ?? 0,
            childAspectRatio: gridDelegate['childAspectRatio'] ?? 0,
          ),
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
      } else if (classname == 'SliverWaterfallDelegate') {
        return WaterfallFlow.builder(
          gridDelegate: SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
            mainAxisSpacing: gridDelegate['mainAxisSpacing'] ?? 0,
            crossAxisSpacing: gridDelegate['crossAxisSpacing'] ?? 0,
            crossAxisCount: gridDelegate['crossAxisCount'] ?? 0,
          ),
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
      }
    }
    return const SizedBox();
  }
}
