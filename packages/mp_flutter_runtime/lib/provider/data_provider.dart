part of '../mp_flutter_runtime.dart';

class MPDataProvider {
  static final _cancelTokens = <String, dio.CancelToken>{};

  static final dioClient = dio.Dio(dio.BaseOptions(headers: {
    'user-agent': 'dio',
  }));

  Future<MPHttpResponse> makeHttpRequest(MPHttpRequest request) async {
    final cancelToken = dio.CancelToken();
    _cancelTokens[request.requestId] = cancelToken;
    final dioOptions = dio.Options(
      method: request.method,
      headers: (() {
        final v = <String, dynamic>{};
        request.header.forEach((key, value) {
          if (key is String) {
            v[key] = value;
          }
        });
        return v;
      })(),
      responseType: dio.ResponseType.bytes,
    );
    final response = await dioClient.request(
      request.url,
      options: dioOptions,
      cancelToken: cancelToken,
      data: request.postBody,
    );
    _cancelTokens.remove(request.requestId);
    return MPHttpResponse(
      statusCode: response.statusCode ?? 0,
      header: response.headers.map.map((key, value) {
        return MapEntry(key, value.join(','));
      }),
      body: response.data,
    );
  }

  void abortHttpRequest(String requestId) {
    _cancelTokens[requestId]?.cancel();
    _cancelTokens.remove(requestId);
  }

  Future<shared_preferences.SharedPreferences> createSharedPreferences() async {
    return await shared_preferences.SharedPreferences.getInstance();
  }
}

class MPHttpRequest {
  final String requestId;
  final String url;
  final String method;
  final Map header;
  final dynamic postBody;

  MPHttpRequest({
    required this.requestId,
    required this.url,
    required this.method,
    required this.header,
    this.postBody,
  });
}

class MPHttpResponse {
  final int statusCode;
  final Map header;
  final Uint8List? body;

  MPHttpResponse({
    required this.statusCode,
    required this.header,
    this.body,
  });
}
