import 'dart:convert';
import 'dart:io';
import 'dart:developer' as dev;

import 'package:flutter/widgets.dart';
import 'package:mime_type/mime_type.dart';
import 'package:mpcore/ga.dart';

import '../mpcore.dart';

import 'package:path/path.dart' as path;
import '../hot_reloader.dart';

class MPChannel {
  static bool _serverSetupped = false;
  static late HttpServer server;
  static List<WebSocket> sockets = [];

  static Future setupHotReload(MPCore minip) async {
    if (HotReloader.isHotReloadable) {
      var info = await dev.Service.getInfo();
      var uri = info.serverUri;
      if (uri == null) return;
      uri = uri.replace(path: path.join(uri.path, 'ws'));
      if (uri.scheme == 'https') {
        uri = uri.replace(scheme: 'wss');
      } else {
        uri = uri.replace(scheme: 'ws');
      }
      print('Hot reloading enabled');
      final reloader = HotReloader(vmServiceUrl: uri.toString());
      reloader.addPath('./lib');
      reloader.addPath('./src');
      reloader.onReload.listen((event) async {
        await minip.handleHotReload();
        MPCore.cancelTextMeasureTask('Hot reload');
        print('Reloaded');
      });
      await reloader.go();
    }
    setupWebServer();
    // ignore: unawaited_futures
    ga.sendEvent('devtools', 'debug');
  }

  static void setupWebServer() async {
    if (_serverSetupped) {
      return;
    }
    _serverSetupped = true;
    try {
      server = await HttpServer.bind('0.0.0.0', 9898, shared: false);
      if (Platform.isWindows) {
        print('Serve on 127.0.0.1:9898');
        print(
            'Use browser open http://127.0.0.1:9898/index.html or use MiniProgram Developer Tools import \'./dist/weapp\' for dev.');
      } else {
        print('Serve on 0.0.0.0:9898');
        print(
            'Use browser open http://127.0.0.1:9898, or http://0.0.0.0:9898/index.html, or use MiniProgram Developer Tools import \'./dist/weapp\' for dev.');
      }
      await for (var req in server) {
        if (req.uri.path == '/ws') {
          if (req.uri.queryParameters['clientType'] == 'browser') {
            MPEnv.debugEnvHost = MPEnvHostType.browser;
          } else if (req.uri.queryParameters['clientType'] ==
              'wechatMiniProgram') {
            MPEnv.debugEnvHost = MPEnvHostType.wechatMiniProgram;
          } else if (req.uri.queryParameters['clientType'] == 'ttMiniProgram') {
            MPEnv.debugEnvHost = MPEnvHostType.ttMiniProgram;
          } else if (req.uri.queryParameters['clientType'] ==
              'playboxProgram') {
            MPEnv.debugEnvHost = MPEnvHostType.playboxProgram;
          } else {
            MPEnv.debugEnvHost = null;
          }
          final socket = await WebSocketTransformer.upgrade(req);
          sockets.add(socket);
          socket.listen(MPChannelBase.handleClientMessage)
            ..onDone(
              () {
                sockets.remove(socket);
                MPCore.cancelTextMeasureTask('Disconnected');
              },
            );
          MPCore.clearOldFrameObject();
          await Future.delayed(Duration(seconds: 1));
          WidgetsBinding.instance?.scheduleFrame();
          _flushMessageQueue();
        } else if (req.uri.path.startsWith('/assets/packages/')) {
          handlePackageAssetsRequest(req);
        } else if (req.uri.path.startsWith('/assets/')) {
          handleAssetsRequest(req);
        } else if (req.uri.path.startsWith('/pubspec.yaml')) {
          handlePubspecRequest(req);
        } else if (req.uri.path.startsWith('/playbox-app.json')) {
          handlePlayBoxAppJSONRequest(req);
        } else if (req.uri.path.startsWith('/app.mpk')) {
          handleAppMpkRequest(req);
        } else {
          handleScaffoldRequest(req);
        }
      }
    } catch (e) {
      print(e);
    }
  }

  static void handlePackageAssetsRequest(HttpRequest request) {
    final pkgName =
        request.uri.path.split('/assets/packages/')[1].split('/')[0];
    final pkgPath = findPackagePath(pkgName);
    if (pkgPath == null) {
      request.response
        ..statusCode = 404
        ..close();
      return;
    }
    final fileComponents =
        request.uri.path.split('/assets/packages/')[1].split('/');
    if (fileComponents[1] == 'assets' && fileComponents[2] == 'assets') {
      fileComponents.removeRange(0, 2);
    } else if (fileComponents[1] == 'assets') {
      fileComponents.removeRange(0, 1);
    }

    final fileName = fileComponents.join('/');
    final mimeType = mime(fileName) ?? 'text/plain; charset=UTF-8';
    request.response.headers
      ..set(
        'Access-Control-Allow-Origin',
        '*',
      )
      ..set(
        'Content-Type',
        mimeType,
      );
    if (File('$pkgPath/$fileName').existsSync()) {
      request.response
        ..statusCode = 200
        ..add(File('$pkgPath/$fileName').readAsBytesSync())
        ..close();
    } else {
      request.response
        ..statusCode = 404
        ..close();
    }
  }

  static String? findPackagePath(String pkgName) {
    final lines = File('./.packages').readAsLinesSync();
    for (final line in lines) {
      if (line.startsWith('$pkgName:')) {
        return line
            .replaceFirst('$pkgName:', '')
            .replaceFirst('file://', '')
            .replaceFirst('/lib/', '');
      }
    }
    return null;
  }

  static void handleAssetsRequest(HttpRequest request) {
    final fileName = request.uri.path.replaceFirst('/assets/', '');
    final mimeType = mime(fileName) ?? 'text/plain; charset=UTF-8';
    request.response.headers
      ..set(
        'Access-Control-Allow-Origin',
        '*',
      )
      ..set(
        'Content-Type',
        mimeType,
      );
    if (File(fileName).existsSync()) {
      request.response
        ..statusCode = 200
        ..add(File(fileName).readAsBytesSync())
        ..close();
    } else if (File('./build/web/assets/$fileName').existsSync()) {
      request.response
        ..statusCode = 200
        ..add(File('./build/web/assets/$fileName').readAsBytesSync())
        ..close();
    } else {
      request.response
        ..statusCode = 404
        ..close();
    }
  }

  static void handlePubspecRequest(HttpRequest request) {
    request.response
      ..statusCode = 200
      ..add(File('./pubspec.yaml').readAsBytesSync())
      ..close();
  }

  static void handlePlayBoxAppJSONRequest(HttpRequest request) async {
    if (File(path.join('lib', 'playbox.config.dart')).existsSync()) {
      try {
        final result = await Process.run('dart', ['./lib/playbox.config.dart']);
        request.response
          ..statusCode = 200
          ..add(utf8.encode((result.stdout as String)))
          // ignore: unawaited_futures
          ..close();
      } catch (e) {
        request.response
          ..statusCode = 500
          // ignore: unawaited_futures
          ..close();
      }
    } else {
      request.response
        ..statusCode = 404
        // ignore: unawaited_futures
        ..close();
    }
  }

  static void handleAppMpkRequest(HttpRequest request) async {
    print('Now is building app.mpk ...');
    try {
      await Process.run('dart', ['scripts/build_mpk.dart']);
      print('app.mpk build success');
      request.response
        ..statusCode = 200
        ..add(File('./build/app.mpk').readAsBytesSync())
        // ignore: unawaited_futures
        ..close();
    } catch (e) {
      print('app.mpk build fail');
      print(e);
      request.response
        ..statusCode = 500
        // ignore: unawaited_futures
        ..close();
    }
  }

  static void handleScaffoldRequest(HttpRequest request) {
    var fileName = request.uri.path;
    if (fileName == '/') {
      fileName = '/index.html';
    }
    final mimeType = mime(fileName) ?? 'text/plain; charset=UTF-8';
    request.response.headers
      ..set(
        'Access-Control-Allow-Origin',
        '*',
      )
      ..set(
        'Content-Type',
        mimeType,
      );
    if (File('./web/' + fileName).existsSync()) {
      request.response
        ..statusCode = 200
        ..add(File('./web/' + fileName).readAsBytesSync())
        ..close();
    } else {
      request.response
        ..statusCode = 404
        ..close();
    }
  }

  static void postMessage(String message, {bool? forLastConnection}) {
    if (sockets.isEmpty) {
      _addMessageToQueue(message);
      return;
    }
    if (forLastConnection == true) {
      sockets.last.add(message);
      return;
    }
    for (var socket in sockets) {
      try {
        socket.add(message);
      } catch (e) {
        print(e);
      }
    }
  }

  static void postMapMessage(Map message, {bool? forLastConnection}) {
    postMessage(json.encode(message), forLastConnection: forLastConnection);
  }

  static final List<String> _messageQueue = [];

  static void _addMessageToQueue(String message) {
    _messageQueue.add(message);
  }

  static void _flushMessageQueue() {
    for (var socket in sockets) {
      try {
        for (var item in _messageQueue) {
          socket.add(item);
        }
      } catch (e) {
        print(e);
      }
    }
    _messageQueue.clear();
  }
}
