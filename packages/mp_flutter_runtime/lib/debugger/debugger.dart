part of '../mp_flutter_runtime.dart';

class _MPDebugger {
  final MPEngine engine;
  final String serverAddr;
  final List<String> _messageQueue = [];
  WebSocketChannel? socket;

  _MPDebugger({
    required this.engine,
    required this.serverAddr,
  });

  void start() {
    socket = IOWebSocketChannel.connect(Uri.parse('ws://$serverAddr/ws'));
    socket!.stream.listen((event) {
      if (_messageQueue.isNotEmpty) {
        for (var msg in _messageQueue) {
          socket?.sink.add(msg);
        }
        _messageQueue.clear();
      }
      if (event is String) {
        engine._didReceivedMessage(event);
      }
    }).onError((_) async {
      Future.delayed(const Duration(seconds: 1));
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
