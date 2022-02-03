part of '../../mp_flutter_runtime.dart';

class _MPPicker extends MPPlatformView {
  _MPPicker({
    Key? key,
    Map? data,
    Map? parentData,
    required _MPComponentFactory componentFactory,
  }) : super(
            key: key,
            data: data,
            parentData: parentData,
            componentFactory: componentFactory);

  List<flutter_picker.PickerItem> getPickerData(BuildContext context) {
    final itemsData = getValueFromAttributes(context, 'items');
    if (itemsData is List) {
      return getPickerItems(itemsData);
    }
    return [];
  }

  List<flutter_picker.PickerItem> getPickerItems(List itemsData) {
    final items = <flutter_picker.PickerItem>[];
    if (itemsData is List) {
      for (final item in itemsData) {
        items.add(flutter_picker.PickerItem(
          text: Text(
            (() {
              final value = item['label'];
              if (value is String) {
                return value;
              } else {
                return '';
              }
            })(),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, height: 2.0),
            maxLines: 1,
          ),
          children: (() {
            final subItems = item['subItems'];
            if (subItems is List) {
              return getPickerItems(subItems);
            }
          })(),
        ));
      }
    }
    return items;
  }

  List<int>? getDefaultValue(BuildContext context) {
    final defaultValue = getValueFromAttributes(context, 'defaultValue');
    if (defaultValue is List) {
      return defaultValue.whereType<int>().toList();
    }
  }

  @override
  Widget builder(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final picker = flutter_picker.Picker(
          hideHeader: true,
          adapter: flutter_picker.PickerDataAdapter(
            data: getPickerData(context),
          ),
          selecteds: getDefaultValue(context),
          cancelText: '取消',
          confirmText: '确认',
          onConfirm: (picker, selected) {
            invokeMethod('callbackResult', {'value': selected});
          },
        );
        picker.showDialog(context);
      },
      child: getWidgetFromChildren(context) ?? const SizedBox(),
    );
  }
}
