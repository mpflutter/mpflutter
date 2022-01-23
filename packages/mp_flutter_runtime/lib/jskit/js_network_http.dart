part of '../mp_flutter_runtime.dart';

class _JSNetworkHttp {
  static Future install(_JSContext context) async {
    context.addMessageListener((message, type) {
      if (type == '\$wx.request') {
        final data = json.decode(message) as Map;
        if (data['func'] == 'request') {
          request(data, context);
        } else if (data['func'] == 'abort') {
          abort(data, context);
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

  static final _cancelTokens = <String, dio.CancelToken>{};

  static final dioClient = dio.Dio(dio.BaseOptions(headers: {
    'user-agent': 'dio',
  }));

  static void request(Map data, _JSContext context) async {
    final seqId = data['seqId'] as String;
    final url = data['url'] as String;
    final method = data['method'] as String?;
    final header = data['header'] as Map?;
    final postBody = data['data'];
    final cancelToken = dio.CancelToken();
    _cancelTokens[seqId] = cancelToken;
    final dioOptions = dio.Options(
      method: method,
      headers: (() {
        final v = <String, dynamic>{};
        header?.forEach((key, value) {
          if (key is String) {
            v[key] = value;
          }
        });
      })(),
      responseType: dio.ResponseType.bytes,
    );
    try {
      final response = await dioClient.request(
        url,
        options: dioOptions,
        cancelToken: cancelToken,
        data: postBody,
      );
      final callbackResult = {
        "data": base64.encode(response.data),
        "header": response.headers.map.map((key, value) {
          return MapEntry(key, value.join(','));
        }),
        "statusCode": response.statusCode,
      };
      context.invokeJSFunc('onWxRequestCallback', [seqId, callbackResult]);
    } catch (e) {
      context.invokeJSFunc('onWxRequestFail', [seqId, e.toString()]);
    }
  }

  static void abort(Map data, _JSContext context) {
    final seqId = data['seqId'] as String;
    _cancelTokens[seqId]?.cancel();
    _cancelTokens.remove(seqId);
    context.invokeJSFunc('onWxRequestAbort', [seqId]);
  }
}
