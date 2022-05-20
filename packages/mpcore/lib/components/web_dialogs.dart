part of '../mpcore.dart';

enum ToastIcon {
  success,
  error,
  loading,
  none,
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

  static Future<String?> prompt({
    required String message,
    String? defaultValue,
    BuildContext? context,
  }) async {
    if (MPEnv.envHost() == MPEnvHostType.ttMiniProgram && context != null) {
      final result = await showMPDialog(
        context: context,
        barrierColor: Colors.black.withOpacity(0.5),
        barrierDismissible: true,
        builder: (context) {
          return MockPrompt(title: message, defaultValue: defaultValue);
        },
      );
      if (result is String) {
        return result;
      }
    } else {
      if (await MPEnv.isWechatMiniProgramOnPC() == true && context != null) {
        final result = await showMPDialog(
          context: context,
          barrierColor: Colors.black.withOpacity(0.5),
          barrierDismissible: true,
          builder: (context) {
            return MockPrompt(title: message, defaultValue: defaultValue);
          },
        );
        if (result is String) {
          return result;
        }
      }
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
}

class MockPrompt extends StatefulWidget {
  final String? title;
  final String? defaultValue;

  MockPrompt({
    this.title,
    this.defaultValue,
  });

  @override
  State<MockPrompt> createState() => _MockPromptState();
}

class _MockPromptState extends State<MockPrompt> {
  final editingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    editingController.text = widget.defaultValue ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AbsorbPointer(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 300,
            color: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 24),
                Text(
                  widget.title ?? '',
                  style: TextStyle(fontSize: 16),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 16.0,
                    right: 16.0,
                    top: 12.0,
                    bottom: 24.0,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 300 - 32,
                      height: 44,
                      color: Colors.black.withOpacity(0.05),
                      child: EditableText(
                        controller: editingController,
                        focusNode: FocusNode(),
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        width: 150,
                        height: 44,
                        child: Center(
                          child: Text(
                            '取消',
                            style: TextStyle(
                              fontSize: 18.0,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop(editingController.text);
                      },
                      child: Container(
                        width: 150,
                        height: 44,
                        child: Center(
                          child: Text(
                            '确定',
                            style: TextStyle(
                              fontSize: 18.0,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
