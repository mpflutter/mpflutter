part of '../mpcore.dart';

class MPAction {
  static final peddingActions = <String, Completer>{};

  static void onActionTrigger(Map message) {
    if (message['event'] == 'callback' && message['id'] is String) {
      peddingActions[message['id']]?.complete(message['data']);
      peddingActions.remove(message['id']);
    }
  }

  final id = UniqueKey().toString();
  final String type;
  final Map params;

  MPAction({required this.type, required this.params});

  Future<dynamic> send() {
    final completer = Completer();
    peddingActions[id] = completer;
    MPChannel.postMessage(
      json.encode({
        'type': 'action:$type',
        'message': {
          'id': id,
          'params': params,
        }
      }),
    );
    return completer.future;
  }
}
