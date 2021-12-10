part of 'mpkit.dart';

class MPVideoView extends MPPlatformView {
  final String url;
  final bool controls;
  final bool autoplay;
  final bool loop;
  final bool muted;
  final String? poster;
  @override
  final MPVideoController? controller;

  MPVideoView({
    required this.url,
    this.controls = true,
    this.autoplay = false,
    this.loop = false,
    this.muted = false,
    this.poster,
    this.controller,
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
          controller: controller,
        );
}

class MPVideoController extends MPPlatformViewController {
  void play() {
    invokeMethod('play');
  }

  void pause() {
    invokeMethod('pause');
  }

  void setVolume(double volume) {
    invokeMethod('setVolume', params: {'volume': volume});
  }

  void volumeUp() {
    invokeMethod('volumeUp');
  }

  void volumeDown() {
    invokeMethod('volumeDown');
  }

  void setMuted(bool muted) {
    invokeMethod('setMuted', params: {'muted': muted});
  }

  void fullscreen() {
    invokeMethod('fullscreen');
  }

  void setPlaybackRate(double playbackRate) {
    invokeMethod('setPlaybackRate', params: {'playbackRate': playbackRate});
  }

  void seekTo(double seekTo) {
    invokeMethod('seekTo', params: {'seekTo': seekTo});
  }

  Future<double> getCurrentTime() async {
    final v = await invokeMethod('getCurrentTime', requireResult: true) as num;
    return v.toDouble();
  }
}
