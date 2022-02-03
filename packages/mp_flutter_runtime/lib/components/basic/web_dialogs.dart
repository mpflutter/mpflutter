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
      await engine.provider.dialogProvider.showAlert(
        context: context,
        message: alertMessage,
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
      final result = await engine.provider.dialogProvider.showConfirm(
        context: context,
        message: alertMessage,
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

  static void prompt(Map data, MPEngine engine) async {
    String? callbackId = data['id'];
    String? alertMessage = data['params']['message'];
    String? defaultValue = data['params']['defaultValue'];
    if (callbackId == null || alertMessage == null) return;
    BuildContext? context =
        engine._managedViews.values.first.getNavigator()?.context;
    if (context != null) {
      final result = await engine.provider.dialogProvider.showPrompt(
        context: context,
        message: alertMessage,
        defaultValue: defaultValue,
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
      final result = await engine.provider.dialogProvider.showActionSheet(
        context: context,
        items: items,
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

  static void showToast(Map data, MPEngine engine) async {
    Map? params = data['params'];
    if (params == null) return;
    String? icon = params['icon'];
    String? title = params['title'];
    int? duration = params['duration'];
    bool? mask = params['mask'];
    BuildContext? context = engine._managedViews.values.last.getContext();
    if (context != null) {
      engine.provider.dialogProvider.showToast(
        context: context,
        icon: icon,
        title: title,
        duration: duration != null ? Duration(milliseconds: duration) : null,
        mask: mask,
      );
    }
  }

  static void hideToast(Map data, MPEngine engine) async {
    engine.provider.dialogProvider.hideToast();
  }
}
