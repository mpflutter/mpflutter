import 'package:mpcore/mpkit/platform_view.dart';

class MPVideoView extends MPPlatformView {
  final String url;
  final bool controls;
  final bool autoplay;
  final bool loop;
  final bool muted;
  final String? poster;

  MPVideoView({
    required this.url,
    this.controls = true,
    this.autoplay = false,
    this.loop = false,
    this.muted = false,
    this.poster,
  }) : super(
          viewType: 'mp_video_view',
          viewAttributes: {
            'url': url,
            'controls': controls,
            'autoplay': autoplay,
            'loop': loop,
            'muted': muted,
            'poster': poster,
          },
        );
}
