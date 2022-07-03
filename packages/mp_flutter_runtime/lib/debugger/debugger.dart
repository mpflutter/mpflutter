part of '../mp_flutter_runtime.dart';

class _MPDebugger extends ChangeNotifier {
  final MPEngine engine;
  final String serverAddr;
  final List<String> _messageQueue = [];
  bool _stopped = false;
  bool _connected = false;
  bool get connected => _connected;

  WebSocketChannel? socket;

  _MPDebugger({
    required this.engine,
    required this.serverAddr,
  });

  void setConnected(bool value) {
    if (_connected == value) return;
    _connected = value;
    notifyListeners();
  }

  void stop() {
    _stopped = true;
  }

  void start() {
    if (_stopped) return;
    socket = IOWebSocketChannel.connect(
      Uri.parse('ws://$serverAddr/ws?clientType=playboxProgram'),
      pingInterval: const Duration(seconds: 600),
    );
    socket!.stream.listen((event) {
      setConnected(true);
      if (_messageQueue.isNotEmpty) {
        for (var msg in _messageQueue) {
          socket?.sink.add(msg);
        }
        _messageQueue.clear();
      }
      if (event is String) {
        engine._didReceivedMessage(event);
      }
    })
      ..onError((_) async {
        setConnected(false);
      })
      ..onDone(() async {
        setConnected(false);
        await Future.delayed(const Duration(seconds: 1));
        start();
      });
  }

  void sendMessage(String message) {
    if (socket != null) {
      socket!.sink.add(message);
    } else {
      _messageQueue.add(message);
    }
  }
}
