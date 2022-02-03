part of '../../mp_flutter_runtime.dart';

class _MPDatePicker extends MPPlatformView {
  _MPDatePicker({
    Key? key,
    Map? data,
    Map? parentData,
    required _MPComponentFactory componentFactory,
  }) : super(
            key: key,
            data: data,
            parentData: parentData,
            componentFactory: componentFactory);

  DateTime? getDateFromAttributes(BuildContext context, String attributeKey) {
    final value = getStringFromAttributes(context, attributeKey);
    if (value != null) {
      try {
        final parts = value.split('-');
        return DateTime.utc(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  @override
  Widget builder(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final result = await showDialog(
          context: context,
          builder: (dialogContext) {
            return DatePickerDialog(
              initialDate: getDateFromAttributes(context, 'defaultValue') ??
                  DateTime.now(),
              firstDate: getDateFromAttributes(context, 'start') ?? DateTime(0),
              lastDate: getDateFromAttributes(context, 'end') ??
                  DateTime.now().add(
                    const Duration(days: 365 * 10),
                  ),
            );
          },
        );
        if (result is DateTime) {
          invokeMethod('callbackResult', {
            'value': [result.year, result.month, result.day]
          });
        }
      },
      child: getWidgetFromChildren(context) ?? const SizedBox(),
    );
  }
}
