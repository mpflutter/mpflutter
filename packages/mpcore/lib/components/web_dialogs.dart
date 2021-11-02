part of '../mpcore.dart';

enum ToastIcon {
  success,
  error,
  loading,
  none,
}

class PickerItem {
  final String label;
  final bool disabled;
  final List<PickerItem>? subItems;

  PickerItem({
    required this.label,
    this.disabled = false,
    this.subItems,
  });

  PickerItem.fromJson(Map<String, dynamic> json)
      : label = json['label'],
        disabled = json['disabled'],
        subItems = json['subItems'];

  Map toJson() {
    return {
      'label': label,
      'disabled': disabled,
      'subItems': subItems,
    };
  }
}

class MPWebDialogs {
  static Future alert({required String message}) {
    return MPAction(
      type: 'web_dialogs',
      params: {'dialogType': 'alert', 'message': message},
    ).send();
  }

  static Future<bool> confirm({required String message}) async {
    final result = await MPAction(
      type: 'web_dialogs',
      params: {'dialogType': 'confirm', 'message': message},
    ).send();
    if (result is bool) {
      return result;
    } else {
      return false;
    }
  }

  static Future<String?> prompt(
      {required String message, String? defaultValue}) async {
    final result = await MPAction(
      type: 'web_dialogs',
      params: {
        'dialogType': 'prompt',
        'message': message,
        'defaultValue': defaultValue
      },
    ).send();
    if (result is String) {
      return result;
    }
  }

  static Future<int?> actionSheet({required List<String> items}) async {
    final result = await MPAction(
      type: 'web_dialogs',
      params: {
        'dialogType': 'actionSheet',
        'items': items,
      },
    ).send();
    if (result is int) {
      return result;
    }
  }

  static void showToast({
    required String title,
    ToastIcon? icon,
    Duration duration = const Duration(milliseconds: 1500),
    bool mask = false,
  }) {
    MPAction(
      type: 'web_dialogs',
      params: {
        'dialogType': 'showToast',
        'title': title,
        'icon': icon?.toString(),
        'duration': duration.inMilliseconds,
        'mask': mask
      },
    ).send();
  }

  static void hideToast() {
    MPAction(
      type: 'web_dialogs',
      params: {
        'dialogType': 'hideToast',
      },
    ).send();
  }

  static void showLoading({
    required String title,
    bool mask = false,
  }) {
    showToast(
      title: title,
      icon: ToastIcon.loading,
      duration: Duration(seconds: 3600),
      mask: mask,
    );
  }

  static void hideLoading() {
    hideToast();
  }

  static Future<List?> showPicker({
    required String title,
    required List<PickerItem> items,
    String? confirmText,
    List<num>? disabledIds,
  }) async {
    final result = await MPAction(
      type: 'web_dialogs',
      params: {
        'dialogType': 'picker',
        'title': title,
        'items': items,
        'confirmText': confirmText,
      },
    ).send();
    return result;
  }

  static Future<List?> showDatePicker({
    required int start,
    required int end,
    List? defaultValue,
  }) async {
    final result = await MPAction(
      type: 'web_dialogs',
      params: {
        'dialogType': 'datePicker',
        'start': start,
        'end': end,
        'defaultValue': defaultValue,
      },
    ).send();
    return result;
  }
}
