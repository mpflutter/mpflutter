part of '../../mp_flutter_runtime.dart';

class _ClipOval extends ComponentView {
  _ClipOval({
    Key? key,
    Map? data,
  }) : super(key: key, data: data);

  @override
  Widget builder(BuildContext context) {
    return ClipOval(
      child: getWidgetFromChildren(context),
    );
  }
}
