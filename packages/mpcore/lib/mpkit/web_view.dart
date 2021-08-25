import 'package:flutter/widgets.dart';
import 'package:mpcore/mpkit/platform_view.dart';

class MPWebView extends MPPlatformView {
  final String url;
  MPWebView({required this.url})
      : super(
          viewType: 'mp_web_view',
          viewAttributes: {'url': url},
        );
}
