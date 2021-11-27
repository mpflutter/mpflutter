part of 'mpkit.dart';

class MPSlider extends StatelessWidget {
  final double min;
  final double max;
  final double step;
  final bool disabled;
  final double width;
  final double value;
  final Function(double)? onValueChanged;

  MPSlider({
    this.min = 0.0,
    this.max = 100.0,
    this.step = 1.0,
    this.disabled = false,
    this.width = 300.0,
    this.value = 0.0,
    this.onValueChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width.toDouble(),
      height: 32,
      alignment: Alignment.centerLeft,
      child: MPPlatformView(
        viewType: 'mp_slider',
        viewAttributes: {
          'min': min,
          'max': max,
          'step': step,
          'disabled': disabled,
          'value': value,
        }..removeWhere((key, value) => value == null),
        onMethodCall: (method, args) {
          if (method == 'onValueChanged' &&
              args is Map &&
              args['value'] is num) {
            onValueChanged?.call((args['value'] as num).toDouble());
          }
        },
      ),
    );
  }
}
