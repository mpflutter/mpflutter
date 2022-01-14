part of './mp_flutter_runtime.dart';

class _MPRouter {
  static Map<String, Completer<int>> routeResponseHandler = {};

  final MPEngine engine;
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
      engine._sendMessage({
        'type': 'router',
        'message': {
          'event': 'updateRoute',
          'routeId': value,
          'viewport': {
            'width': viewport?.width ?? 0,
            'height': viewport?.height ?? 0,
          },
        }
      });
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
          'width': viewport?.width ?? 0,
          'height': viewport?.height ?? 0,
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

  void _didPush(Map message) {
    if (engine._managedViews.isEmpty) return;
    MPDataReceiver dataReceiver = engine._managedViews.values.first;
    NavigatorState? navigator = dataReceiver.getNavigator();
    if (navigator == null) return;
    int? routeId = message['routeId'];
    thePushingRouteId = routeId;
    navigator.push(
      MaterialPageRoute(
        builder: (context) {
          return MPPage(engine: engine);
        },
        settings: RouteSettings(
          name: message['name'],
          arguments: message['params'],
        ),
      ),
    );
  }

  void _didReplace(Map message) {
    if (engine._managedViews.isEmpty) return;
    MPDataReceiver dataReceiver = engine._managedViews.values.first;
    NavigatorState? navigator = dataReceiver.getNavigator();
    if (navigator == null) return;
    int? routeId = message['routeId'];
    thePushingRouteId = routeId;
    navigator.pushReplacement(
      MaterialPageRoute(
        builder: (context) {
          return MPPage(engine: engine);
        },
        settings: RouteSettings(
          name: message['name'],
          arguments: message['params'],
        ),
      ),
    );
  }

  void _didPop() async {
    if (engine._managedViews.isEmpty) return;
    MPDataReceiver dataReceiver = engine._managedViews.values.first;
    NavigatorState? navigator = dataReceiver.getNavigator();
    if (navigator == null) return;
    doBacking = true;
    navigator.pop();
    doBacking = false;
  }

  void _disposeRoute(int viewId) {
    if (doBacking) {
      return;
    }
    engine._sendMessage({
      'type': 'router',
      'message': {
        'event': 'disposeRoute',
        'routeId': viewId,
      },
    });
  }
}
