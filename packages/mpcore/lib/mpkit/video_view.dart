import 'package:flutter/widgets.dart';

class MPVideoView extends StatelessWidget {
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
  });

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
