part of '../mp_flutter_runtime.dart';

class _JSNetworkHttp {
  static Future install(_JSContext context, MPEngine engine) async {
    context.addMessageListener((message, type) {
      if (type == '\$wx.request') {
        final data = json.decode(message) as Map;
        if (data['func'] == 'request') {
          request(data, context, engine);
        } else if (data['func'] == 'abort') {
          abort(data, context, engine);
        }
      }
    });
    await context.evaluateScript('''
    globalThis.wxRequestHandlers = {};
    let networkTaskSeqId = 0;
    function generateTaskSeqId() {
      let currentId = networkTaskSeqId;
      networkTaskSeqId++;
      return '${context.hashCode}_' + currentId;
    }
    globalThis.onWxRequestCallback = function(seqId, data) {
      globalThis.wxRequestHandlers[seqId].success(data);
      delete globalThis.wxRequestHandlers[seqId];
    };
    globalThis.onWxRequestFail = function(seqId, e) {
      globalThis.wxRequestHandlers[seqId].fail(e);
      delete globalThis.wxRequestHandlers[seqId];
    };
    globalThis.onWxRequestAbort = function(seqId) {
      delete globalThis.wxRequestHandlers[seqId];
    };
    globalThis.wx.request = function(options) {
      let seqId = generateTaskSeqId();
      globalThis.postMessage(JSON.stringify(Object.assign({func: 'request', seqId: seqId}, options)), '\$wx.request');
      globalThis.wxRequestHandlers[seqId] = options;
      return {
        seqId: seqId,
        abort: function() {
          globalThis.postMessage(JSON.stringify(Object.assign({func: 'abort', seqId: seqId})), '\$wx.request');
        },
      };
    };
    ''');
  }

  static void request(Map data, _JSContext context, MPEngine engine) async {
    final seqId = data['seqId'] as String;
    final url = data['url'] as String;
    final method = data['method'] as String?;
    final header = data['header'] as Map?;
    final postBody = data['data'];
    try {
      final response = await engine.provider.dataProvider.makeHttpRequest(
        MPHttpRequest(
          requestId: seqId,
          url: url,
          method: method ?? 'GET',
          header: (() {
            final v = <String, dynamic>{};
            header?.forEach((key, value) {
              if (key is String) {
                v[key] = value;
              }
            });
            return v;
          })(),
          postBody: postBody,
        ),
      );
      final callbackResult = {
        "data": response.body != null ? base64.encode(response.body!) : null,
        "header": response.header,
        "statusCode": response.statusCode,
      };
      context.invokeJSFunc('onWxRequestCallback', [seqId, callbackResult]);
    } catch (e) {
      context.invokeJSFunc('onWxRequestFail', [seqId, e.toString()]);
    }
  }

  static void abort(Map data, _JSContext context, MPEngine engine) {
    final seqId = data['seqId'] as String;
    engine.provider.dataProvider.abortHttpRequest(seqId);
    context.invokeJSFunc('onWxRequestAbort', [seqId]);
  }
}
