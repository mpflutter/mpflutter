// ignore: avoid_web_libraries_in_flutter

import 'dart:convert';
import 'dart:js' as js;

import '../mpcore.dart';

js.JsObject engineScope = js.context['engineScope'];
bool envSupportProxyObject = js.context['enableMPProxy'] == true ||
    (js.context['disableMPProxy'] != true &&
        js.context['Proxy'] is js.JsFunction);

class MPChannel {
  static bool _isClientAttached = false;

  static void setupHotReload(MPCore minip) async {
    _setupLocalServer();
  }

  static void _setupLocalServer() async {
    _isClientAttached = true;
    engineScope['postMessage'] = (String message) {
      MPChannelBase.handleClientMessage(message);
    };
    _flushMessageQueue();
  }

  static void postMessage(String message, {bool? forLastConnection}) {
    if (!_isClientAttached) {
      _addMessageToQueue(message);
      return;
    }
    engineScope.callMethod('onMessage', [message]);
  }

  static void postMapMessage(Map message, {bool? forLastConnection}) {
    if (!envSupportProxyObject) {
      final str = json.encode(message);
      return postMessage(str, forLastConnection: forLastConnection);
    }
    if (!_isClientAttached) {
      postMessage(json.encode(message), forLastConnection: forLastConnection);
      return;
    }
    engineScope.callMethod('onMapMessage', [message]);
  }

  static final List<String> _messageQueue = [];

  static void _addMessageToQueue(String message) {
    _messageQueue.add(message);
  }

  static void _flushMessageQueue() {
    for (var item in _messageQueue) {
      engineScope.callMethod('onMessage', [item]);
    }
    _messageQueue.clear();
  }
}
