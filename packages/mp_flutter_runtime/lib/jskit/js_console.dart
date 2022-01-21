part of '../mp_flutter_runtime.dart';

class _JSConsole {
  static Future install(_JSContext context) async {
    context.addMessageListener((message, type) {
      if (type == '\$console') {
        final messageObj = json.decode(message);
        for (var it in (messageObj['args'] as List)) {
          // ignore: avoid_print
          print('[${messageObj['level']}] > $it');
        }
      }
    });
    await context.evaluateScript('''
    globalThis.console = {
      log: function() {
        let args = [];
        for (let i = 0; i < arguments.length; i++) {
          args.push(arguments[i]);
        }
        globalThis.postMessage(JSON.stringify({
          level: 'log',
          args: args,
        }), '\$console');
      },
      info: function() {
        let args = [];
        for (let i = 0; i < arguments.length; i++) {
          args.push(arguments[i]);
        }
        globalThis.postMessage(JSON.stringify({
          level: 'info',
          args: args,
        }), '\$console');
      },
      error: function() {
        let args = [];
        for (let i = 0; i < arguments.length; i++) {
          args.push(arguments[i]);
        }
        globalThis.postMessage(JSON.stringify({
          level: 'error',
          args: args,
        }), '\$console');
      },
      debug: function() {
        let args = [];
        for (let i = 0; i < arguments.length; i++) {
          args.push(arguments[i]);
        }
        globalThis.postMessage(JSON.stringify({
          level: 'debug',
          args: args,
        }), '\$console');
      },
      warn: function() {
        let args = [];
        for (let i = 0; i < arguments.length; i++) {
          args.push(arguments[i]);
        }
        globalThis.postMessage(JSON.stringify({
          level: 'warn',
          args: args,
        }), '\$console');
      },
    }
    ''');
  }
}
