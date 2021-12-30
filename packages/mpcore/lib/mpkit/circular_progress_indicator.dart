part of 'mpkit.dart';

class MPCircularProgressIndicator extends MPPlatformView {
  final double size;
  final Color color;

  MPCircularProgressIndicator({
    this.size = 36,
    this.color = Colors.black,
  }) : super(
          viewType: 'mp_circular_progress_indicator',
          viewAttributes: {
            'size': size,
            'color': color.value.toString(),
          },
          child: Container(
            width: size,
            height: size,
            color: Colors.transparent,
          ),
        );
}
