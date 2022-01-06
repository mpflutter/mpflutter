part of './mp_flutter_runtime.dart';

class _MPRouter {
  static Map<String, Completer<int>> routeResponseHandler = {};

  MPEngine engine;
  bool doBacking = false;
  int? thePushingRouteId;

  _MPRouter({required this.engine});

  Future<int> requestRoute({
    String? routeName,
    Map? routeParams,
    bool? isRoot,
    Size? viewport,
  }) async {
    if (thePushingRouteId != null) {
      int value = thePushingRouteId!;
      thePushingRouteId = null;
      // todo update route.
      return value;
    }
    String requestId = Random().nextDouble().toString();
    final completer = Completer<int>();
    routeResponseHandler[requestId] = completer;
    engine._sendMessage({
      'type': 'router',
      'message': {
        'event': 'requestRoute',
        'requestId': requestId,
        'name': routeName ?? '/',
        'params': routeParams ?? {},
        'viewport': {
          'width': 375,
          'height': 667,
        },
        'root': isRoot ?? false,
      },
    });
    return completer.future;
  }

  void _didReceivedRouteData(Map message) {
    String? event = message['event'];
    if (event == null) return;
    switch (event) {
      case 'responseRoute':
        _responseRoute(message);
        break;
      case 'didPush':
        _didPush(message);
        break;
      case 'didReplace':
        _didReplace(message);
        break;
      case 'didPop':
        _didPop();
        break;
      default:
    }
  }

  void _responseRoute(Map message) {
    String requestId = message['requestId'];
    int routeId = message['routeId'];
    if (routeResponseHandler.containsKey(requestId)) {
      routeResponseHandler[requestId]!.complete(routeId);
      routeResponseHandler.remove(requestId);
    }
  }

  void _didPush(Map message) {}

  void _didReplace(Map message) {}

  void _didPop() {}
}
