part of '../../mp_flutter_runtime.dart';

class _ListView extends ComponentView {
  _ListView({
    Key? key,
    Map? data,
  }) : super(key: key, data: data);

  @override
  Widget builder(BuildContext context) {
    final childrenWidget = getWidgetsFromChildren(context);
    if (childrenWidget == null) {
      return const SizedBox();
    }
    return ListView.builder(
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
