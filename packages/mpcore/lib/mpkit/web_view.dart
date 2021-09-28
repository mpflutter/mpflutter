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

  @override
  final MPWebViewController? controller;

  MPWebView({required this.url, this.controller})
      : super(
          viewType: 'mp_web_view',
          viewAttributes: {'url': url},
          controller: controller,
        );
}
