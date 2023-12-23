import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:async/async.dart';
import 'package:flutter/foundation.dart';
import 'package:mpflutter_core/logger.dart';

import 'package:uuid/v4.dart';

String? getTempDirectoryPath() {
  final homeDir = getHomeDirectory();
  if (homeDir != null) {
    if (Platform.isMacOS || Platform.isLinux) {
      String tempPath = '$homeDir/Downloads/mpflutter_temp';
      return tempPath;
    } else if (Platform.isWindows) {
      String tempPath = '$homeDir/mpflutter_temp';
      return tempPath;
    }
  }
  return null;
}

String? getHomeDirectory() {
  if (Platform.isMacOS || Platform.isLinux) {
    return Platform.environment['HOME'];
  } else if (Platform.isWindows) {
    return Platform.environment['USERPROFILE'];
  }
  return null;
}

class IsolateDevServer extends ChangeNotifier {
  static final shared = IsolateDevServer();

  final _tempPath = getTempDirectoryPath();
  final hostPort = ReceivePort();
  SendPort? hostSendPort;
  void Function(String, Map)? eventListenner;
  bool serverConnected = false;

  connected() {
    return serverConnected;
  }

  start() async {
    if (_tempPath == null) {
      throw "无法获取临时存储目录，请联系官方。";
    }
    Directory(_tempPath!).createSync(recursive: true);
    Isolate.spawn((hostSendPort) async {
      Logger.logLevel = LogLevel.info;
      final _tempPath = getTempDirectoryPath();
      final clientPort = ReceivePort();
      hostSendPort.send(clientPort.sendPort);
      DevServer.shared.addListener(() {
        hostSendPort.send(
          {"serverConnected": DevServer.shared._activeClient != null},
        );
      });
      DevServer.shared.start();
      DevServer.shared.eventListenner = (p0, p1) {
        hostSendPort.send(
          json.encode({"msgType": "event", "method": p0, "params": p1}),
        );
      };
      clientPort.asBroadcastStream().listen((hostMessage) async {
        if (hostMessage is String) {
          final hostMsgObj = json.decode(hostMessage);
          if (!(hostMsgObj is Map)) return;
          if (hostMsgObj['cmd'] == "invokeMethod") {
            final id = hostMsgObj["id"] as String;
            final result = await DevServer.shared.invokeMethod(
              hostMsgObj['method'],
              hostMsgObj['params'],
            );
            File("$_tempPath/data_$id").writeAsStringSync(json.encode(result));
          } else if (hostMsgObj['cmd'] == "stop") {
            DevServer.shared.stop();
            Isolate.exit();
          }
        }
      });
    }, hostPort.sendPort);
    final events = StreamQueue<dynamic>(hostPort);
    hostSendPort = await events.next;
    while (true) {
      final isolateMsg = await events.next;
      if (isolateMsg is Map && isolateMsg["serverConnected"] is bool) {
        serverConnected = isolateMsg["serverConnected"];
        notifyListeners();
      }
      if (isolateMsg is String) {
        try {
          final msg = json.decode(isolateMsg);
          Logger.debug('MPJS: receive event => $msg');
          if (msg["msgType"] == "event") {
            eventListenner?.call(msg["method"], msg["params"]);
          }
        } catch (e) {}
      }
    }
  }

  dynamic invokeMethod(String method, Map params) {
    final id = UuidV4().generate();
    hostSendPort?.send(json.encode({
      "cmd": "invokeMethod",
      "id": id,
      "method": method,
      "params": params,
    }));
    final file = File("$_tempPath/data_$id");
    dynamic content;
    var retryCount = 0;
    while (true) {
      if (retryCount > 2000) {
        throw Error.safeToString("未连接到调试宿主");
      }
      if (file.existsSync()) {
        final fileContent = file.readAsStringSync();
        if (!fileContent.isEmpty) {
          content = json.decode(fileContent);
          file.delete();
          break;
        }
      }
      final delayTime = 5;
      retryCount += delayTime;
      sleep(Duration(milliseconds: delayTime));
    }
    return content;
  }

  stop() {
    hostPort.sendPort.send(json.encode({
      "cmd": "stop",
    }));
  }
}

class DevServer extends ChangeNotifier {
  static final shared = DevServer();

  // ignore: unused_field
  late HttpServer _server;
  WebSocket? _activeClient;
  Map<String, Completer> _invokeMethodCompleters = {};
  void Function(String, Map)? eventListenner;

  start() async {
    final server = await HttpServer.bind(InternetAddress.anyIPv4, 9898);
    Logger.info('调试服务器已启动，IP = 127.0.0.1，端口 = 9898');
    _server = server;
    await for (HttpRequest request in server) {
      final socket = await WebSocketTransformer.upgrade(request);
      _activeClient = socket;
      Logger.info('调试宿主已连接');
      notifyListeners();
      socket.listen((message) {
        receiveMethodResponse(message);
      });
      socket.done.then((value) {
        Logger.info('调试宿主已断开');
        socket.close();
        _activeClient = null;
        notifyListeners();
      });
    }
  }

  stop() {
    _server.close(force: true);
  }

  Future<dynamic> invokeMethod(String method, Map params) async {
    Logger.debug('MPJS: invokeMethod, method = $method, params = $params');
    final client = _activeClient;
    final id = UuidV4().generate();
    final completer = Completer();
    _invokeMethodCompleters[id] = completer;
    if (client != null) {
      client.add(json.encode({
        "id": id,
        "method": method,
        "params": params,
      }));
    }
    return completer.future;
  }

  void receiveMethodResponse(String message) {
    Logger.debug('MPJS: receiveMethodResponse => $message');
    try {
      final obj = json.decode(message);
      if (obj is Map) {
        final id = obj["id"];
        final method = obj["method"];
        if (id is String && _invokeMethodCompleters[id] != null) {
          if (obj["error"] != null) {
            _invokeMethodCompleters[id]?.completeError(obj["error"]);
            return;
          }
          _invokeMethodCompleters[id]?.complete(obj["result"]);
        } else if (method is String) {
          eventListenner?.call(method, obj["params"]);
        }
      }
    } catch (e) {}
  }
}
