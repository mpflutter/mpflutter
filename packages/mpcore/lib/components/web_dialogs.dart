part of '../mpcore.dart';

class MPWebDialogs {
  static Future alert({required String message}) {
    return MPAction(
      type: 'web_dialogs',
      params: {'dialogType': 'alert', 'message': message},
    ).send();
  }

  static Future confirm({required String message}) {
    return MPAction(
      type: 'web_dialogs',
      params: {'dialogType': 'confirm', 'message': message},
    ).send();
  }

  static Future prompt({required String message, String? defaultValue}) {
    return MPAction(
      type: 'web_dialogs',
      params: {
        'dialogType': 'prompt',
        'message': message,
        'defaultValue': defaultValue
      },
    ).send();
  }
}
