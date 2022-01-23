part of '../../mp_flutter_runtime.dart';

class _WebDialogs {
  static void didReceivedWebDialogsMessage(Map data, MPEngine engine) {
    Map? params = data['params'];
    if (params == null) return;
    String? dialogType = params['dialogType'];
    if (dialogType == null) return;
    switch (dialogType) {
      case 'alert':
        alert(data, engine);
        break;
      case 'confirm':
        confirm(data, engine);
        break;
      case 'prompt':
        prompt(data, engine);
        break;
      case 'actionSheet':
        actionSheet(data, engine);
        break;
      case 'showToast':
        showToast(data, engine);
        break;
      case 'hideToast':
        hideToast(data, engine);
        break;
      default:
    }
  }

  static void alert(Map data, MPEngine engine) async {
    String? callbackId = data['id'];
    String? alertMessage = data['params']['message'];
    if (callbackId == null || alertMessage == null) return;
    BuildContext? context =
        engine._managedViews.values.first.getNavigator()?.context;
    if (context != null) {
      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text(alertMessage),
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
      engine._sendMessage({
        'type': 'action',
        'message': {
          'event': 'callback',
          'id': callbackId,
        },
      });
    }
  }

  static void confirm(Map data, MPEngine engine) async {
    String? callbackId = data['id'];
    String? alertMessage = data['params']['message'];
    if (callbackId == null || alertMessage == null) return;
    BuildContext? context =
        engine._managedViews.values.first.getNavigator()?.context;
    if (context != null) {
      final result = await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text(alertMessage),
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
      engine._sendMessage({
        'type': 'action',
        'message': {
          'event': 'callback',
          'id': callbackId,
          'data': result == true,
        },
      });
    }
  }

  static void prompt(Map data, MPEngine engine) async {
    String? callbackId = data['id'];
    String? alertMessage = data['params']['message'];
    String? defaultValue = data['params']['defaultValue'];
    if (callbackId == null || alertMessage == null) return;
    BuildContext? context =
        engine._managedViews.values.first.getNavigator()?.context;
    if (context != null) {
      final controller = TextEditingController();
      controller.text = defaultValue ?? '';
      final result = await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(alertMessage),
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
      engine._sendMessage({
        'type': 'action',
        'message': {
          'event': 'callback',
          'id': callbackId,
          'data': result,
        },
      });
    }
  }

  static void actionSheet(Map data, MPEngine engine) async {
    String? callbackId = data['id'];
    List? items = data['params']['items'];
    if (callbackId == null || items == null) return;
    BuildContext? context =
        engine._managedViews.values.first.getNavigator()?.context;
    if (context != null) {
      final result = await showModalBottomSheet(
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
      engine._sendMessage({
        'type': 'action',
        'message': {
          'event': 'callback',
          'id': callbackId,
          'data': result,
        },
      });
    }
  }

  static OverlayEntry? activeHUD;

  static void showToast(Map data, MPEngine engine) async {
    if (activeHUD != null) {
      try {
        activeHUD!.remove();
        // ignore: empty_catches
      } catch (e) {}
    }
    Map? params = data['params'];
    if (params == null) return;
    String? icon = params['icon'];
    String? title = params['title'];
    int? duration = params['duration'];
    bool? mask = params['mask'];
    BuildContext? context = engine._managedViews.values.last.getContext();
    if (context != null) {
      final overlayEntry = OverlayEntry(builder: (context) {
        final content = Center(
          child: Container(
            height: 100,
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
        Future.delayed(Duration(milliseconds: duration)).then((value) {
          try {
            overlayEntry.remove();
            // ignore: empty_catches
          } catch (e) {}
        });
      }
    }
  }

  static void hideToast(Map data, MPEngine engine) async {
    if (activeHUD != null) {
      try {
        activeHUD!.remove();
        // ignore: empty_catches
      } catch (e) {}
    }
  }
}
