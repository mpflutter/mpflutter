import 'dart:convert';
import 'dart:io';
import 'dart:developer' as dev;

import 'package:flutter/widgets.dart';
import 'package:mime_type/mime_type.dart';

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
  }

  static void setupWebServer() async {
    if (_serverSetupped) {
      return;
    }
    _serverSetupped = true;
    try {
      server = await HttpServer.bind('0.0.0.0', 9898, shared: false);
      print('Serve on 0.0.0.0:9898');
      print(
          'Use browser open http://0.0.0.0:9898/index.html or use MiniProgram Developer Tools import \'./dist/weapp\' for dev.');
      await for (var req in server) {
        if (req.uri.path == '/ws') {
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
          WidgetsBinding.instance?.scheduleFrame();
          _flushMessageQueue();
        } else if (req.uri.path.startsWith('/assets/packages/')) {
          handlePackageAssetsRequest(req);
        } else if (req.uri.path.startsWith('/assets/')) {
          handleAssetsRequest(req);
        } else if (req.uri.path.startsWith('/bundle.') ||
            req.uri.path.startsWith('/index.html') ||
            req.uri.path.startsWith('/index.css') ||
            req.uri.path.startsWith('/main.dart.js') ||
            req.uri.path.startsWith('/static/')) {
          handleScaffoldRequest(req);
        } else if (req.uri.path == '/') {
          handleScaffoldRequest(req);
        } else {
          final _ = req.response.close();
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
    if (fileName == 'mp_plugins.js') {
      handlePluginJSRequest(request);
    } else if (fileName == 'mp_plugins.css') {
      handlePluginCSSRequest(request);
    } else if (File(fileName).existsSync()) {
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

  static void handlePluginJSRequest(HttpRequest request) {
    final stringBuffer = StringBuffer();
    final lines = File('./.packages').readAsLinesSync();
    for (final line in lines) {
      final pkgPath = line
          .replaceFirst(RegExp('.*?:'), '')
          .replaceFirst('file://', '')
          .replaceFirst('/lib/', '');
      if (File('$pkgPath/web/dist/index.min.js').existsSync()) {
        stringBuffer
            .writeln(File('$pkgPath/web/dist/index.min.js').readAsStringSync());
      }
    }
    request.response
      ..statusCode = 200
      ..add(utf8.encode(stringBuffer.toString()))
      ..close();
  }

  static void handlePluginCSSRequest(HttpRequest request) {
    final stringBuffer = StringBuffer();
    final lines = File('./.packages').readAsLinesSync();
    for (final line in lines) {
      final pkgPath = line
          .replaceFirst(RegExp('.*?:'), '')
          .replaceFirst('file://', '')
          .replaceFirst('/lib/', '');
      if (File('$pkgPath/web/dist/index.css').existsSync()) {
        stringBuffer
            .writeln(File('$pkgPath/web/dist/index.css').readAsStringSync());
      }
    }
    request.response
      ..statusCode = 200
      ..add(utf8.encode(stringBuffer.toString()))
      ..close();
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

  static void postMesssage(String message, {bool? forLastConnection}) {
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
