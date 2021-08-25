part of 'mpkit.dart';

class MPWebView extends MPPlatformView {
  final String url;
  MPWebView({required this.url})
      : super(
          viewType: 'mp_web_view',
          viewAttributes: {'url': url},
        );
}
