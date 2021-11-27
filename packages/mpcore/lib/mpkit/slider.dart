part of 'mpkit.dart';

class MPSlider extends StatelessWidget {
  final int min;
  final int max;
  final int step;
  final bool disabled;
  final int width;
  final int value;
  final Function(Map)? onValueChanged;

  MPSlider({
    this.min = 0,
    this.max = 100,
    this.step = 1,
    this.disabled = false,
    this.width = 300,
    this.value = 0,
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
          if (method == 'onValueChanged' && args is Map) {
            onValueChanged?.call(args);
          }
        },
      ),
    );
  }
}
