part of '../mp_flutter_runtime.dart';

class MPDialogProvider {
  Future showAlert({
    required BuildContext context,
    required String message,
  }) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(message),
          actions: [
            MaterialButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('好的'),
            )
          ],
        );
      },
    );
  }

  Future<bool> showConfirm({
    required BuildContext context,
    required String message,
  }) async {
    return await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          content: Text(message),
          actions: [
            MaterialButton(
              minWidth: 28,
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text(
                '确认',
                style: TextStyle(color: Colors.red),
              ),
            ),
            MaterialButton(
              minWidth: 28,
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('取消'),
            ),
          ],
        );
      },
    );
  }

  Future<String?> showPrompt({
    required BuildContext context,
    required String message,
    String? defaultValue,
  }) async {
    final controller = TextEditingController();
    controller.text = defaultValue ?? '';
    return await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(message),
          content: TextField(controller: controller),
          actions: [
            MaterialButton(
              minWidth: 28,
              onPressed: () {
                Navigator.of(context).pop(null);
              },
              child: const Text('取消'),
            ),
            MaterialButton(
              minWidth: 28,
              onPressed: () {
                Navigator.of(context).pop(controller.text);
              },
              child: const Text(
                '确认',
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<int?> showActionSheet({
    required BuildContext context,
    required List items,
  }) async {
    return await showModalBottomSheet(
      context: context,
      builder: (context) {
        final widgets = <Widget>[];
        int index = 0;
        for (final e in items) {
          int currentIndex = index;
          widgets.add(ListTile(
            onTap: () {
              Navigator.of(context).pop(currentIndex);
            },
            title: Center(child: Text('$e')),
          ));
          widgets.add(const Divider(height: 1));
          index++;
        }
        widgets.add(ListTile(
          onTap: () {
            Navigator.of(context).pop(null);
          },
          title: const Center(child: Text('取消')),
        ));
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: widgets,
        );
      },
    );
  }

  OverlayEntry? activeHUD;

  void showToast({
    required BuildContext context,
    String? icon,
    String? title,
    Duration? duration,
    bool? mask,
  }) {
    if (activeHUD != null) {
      try {
        activeHUD!.remove();
        // ignore: empty_catches
      } catch (e) {}
    }
    final overlayEntry = OverlayEntry(builder: (context) {
      final content = Center(
        child: Container(
          height: 128,
          width: 128,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.only(
              left: 32.0,
              right: 32.0,
              top: 16.0,
              bottom: 16.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                icon != null
                    ? (() {
                        switch (icon) {
                          case 'ToastIcon.success':
                            return const Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: 36,
                            );
                          case 'ToastIcon.error':
                            return const Icon(
                              Icons.error,
                              color: Colors.white,
                              size: 36,
                            );
                          case 'ToastIcon.loading':
                            return Transform.scale(
                              scale: 0.75,
                              child: const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation(
                                  Colors.white,
                                ),
                              ),
                            );
                          default:
                            return const SizedBox();
                        }
                      })()
                    : const SizedBox(),
                title != null
                    ? Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: Text(title,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              decoration: TextDecoration.none,
                            )),
                      )
                    : const SizedBox(),
              ],
            ),
          ),
        ),
      );
      if (mask == true) {
        return Container(
          color: Colors.transparent,
          child: content,
        );
      } else {
        return content;
      }
    });
    activeHUD = overlayEntry;
    Overlay.of(context)?.insert(overlayEntry);
    if (duration != null) {
      Future.delayed(duration).then((value) {
        try {
          overlayEntry.remove();
          if (activeHUD == overlayEntry) {
            activeHUD = null;
          }
          // ignore: empty_catches
        } catch (e) {}
      });
    }
  }

  void hideToast() {
    if (activeHUD != null) {
      try {
        activeHUD!.remove();
        activeHUD = null;
        // ignore: empty_catches
      } catch (e) {}
    }
  }
}
