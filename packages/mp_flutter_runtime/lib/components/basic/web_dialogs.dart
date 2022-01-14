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
}
