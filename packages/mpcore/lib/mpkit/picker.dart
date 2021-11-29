part of 'mpkit.dart';

class MPPickerItem {
  final String label;
  final bool disabled;
  final List<MPPickerItem>? subItems;

  MPPickerItem({
    required this.label,
    this.disabled = false,
    this.subItems,
  });

  MPPickerItem.fromJson(Map<String, dynamic> json)
      : label = json['label'],
        disabled = json['disabled'],
        subItems = json['subItems'];

  Map toJson() {
    return {
      'label': label,
      'disabled': disabled,
      'subItems': subItems?.map((e) => e.toJson()).toList(),
    };
  }
}

class MPDatePicker extends MPPlatformView {
  final Function(DateTime)? onResult;

  MPDatePicker({
    required Widget child,
    String? headerText,
    bool? disabled,
    DateTime? start,
    DateTime? end,
    DateTime? defaultValue,
    this.onResult,
  }) : super(
            viewType: 'mp_date_picker',
            viewAttributes: {
              'headerText': headerText,
              'disabled': disabled,
              'start': start != null
                  ? '${start.year}-${start.month}-${start.day}'
                  : null,
              'end': end != null ? '${end.year}-${end.month}-${end.day}' : null,
              'defaultValue': defaultValue != null
                  ? '${defaultValue.year}-${defaultValue.month}-${defaultValue.day}'
                  : null,
            }..removeWhere((key, value) => value == null),
            child: child,
            onMethodCall: (method, params) {
              if (method == 'callbackResult' && params?['value'] is List) {
                final value = params?['value'] as List;
                onResult?.call(DateTime(value[0], value[1], value[2]));
              }
            });
}

class MPPicker extends MPPlatformView {
  final Function(List<MPPickerItem>)? onResult;

  MPPicker({
    required Widget child,
    required int column,
    List<MPPickerItem>? items,
    String? headerText,
    bool? disabled,
    List<int>? defaultValue,
    this.onResult,
  }) : super(
            viewType: 'mp_picker',
            viewAttributes: {
              'items': items?.map((e) => e.toJson()).toList(),
              'column': column,
              'headerText': headerText,
              'disabled': disabled,
              'defaultValue': defaultValue,
            }..removeWhere((key, value) => value == null),
            child: child,
            onMethodCall: (method, params) {
              if (method == 'callbackResult' && params?['value'] is List) {
                if (items == null) return;
                final value = params?['value'] as List;
                final resultItems = <MPPickerItem>[];
                MPPickerItem? currentItem = items[value[0]];
                resultItems.add(currentItem);
                for (var i = 1; i < value.length; i++) {
                  currentItem = currentItem?.subItems?[value[i]];
                  if (currentItem == null) {
                    break;
                  }
                  resultItems.add(currentItem);
                }
                onResult?.call(resultItems);
              }
            });
}
