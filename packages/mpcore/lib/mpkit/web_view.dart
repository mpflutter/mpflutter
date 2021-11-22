part of 'mpkit.dart';

class MPWebViewController extends MPPlatformViewController {
  void reload() {
    invokeMethod('reload', requireResult: true);
  }

  void loadUrl(String url) {
    invokeMethod('loadUrl', params: {'url': url});
  }
}

class MPWebView extends MPPlatformView {
  final String url;
  final Function(List<dynamic>)? onMiniProgramMessage;

  @override
  final MPWebViewController? controller;

  MPWebView({required this.url, this.controller, this.onMiniProgramMessage})
      : super(
            viewType: 'mp_web_view',
            viewAttributes: {'url': url},
            controller: controller,
            onMethodCall: (method, arguments) {
              if (method == 'mini_program_message' &&
                  arguments is Map &&
                  arguments['data'] is List) {
                if (onMiniProgramMessage != null) {
                  onMiniProgramMessage.call(arguments['data'] as List);
                }
              }
            });
}
