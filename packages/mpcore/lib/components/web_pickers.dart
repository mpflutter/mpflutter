part of '../mpcore.dart';

class MPWebPickers {
  static Future<int?> showSinglePicker({
    required String title,
    required List<String> items,
  }) async {
    final result = await MPAction(
      type: 'web_pickers',
      params: {
        'pickerType': 'single',
        'title': title,
        'items': items,
      },
    ).send();
    if (result is int) {
      return result;
    }
  }
}
