part of 'mpkit.dart';

class MPSlider extends StatelessWidget {
  final int width;
  final int? value;
  final Function(Map)? onSliderChange;
  final Function(Map)? onSliderChanging;

  MPSlider({
    // int? min,
    // int? max,
    // int? step,
    // bool? disabled,
    this.width = 300,
    this.value,
    // Color? activeColor,
    // Color? backgroundColor,
    // int? blockSize,
    // Color? blockColor,
    // bool? showValue,
    this.onSliderChange,
    this.onSliderChanging,
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
          // 'min': min,
          // 'max': max,
          // 'step': step,
          // 'disabled': disabled,
          'value': value,
          // 'activeColor':
          //     activeColor == null ? null : activeColor.value.toString(),
          // 'backgroundColor':
          //     backgroundColor == null ? null : backgroundColor.value.toString(),
          // 'blockSize': blockSize,
          // 'blockColor': blockColor == null ? null : blockColor.value.toString(),
          // 'showValue': showValue,
        }..removeWhere((key, value) => value == null),
        onMethodCall: (method, args) {
          if (method == 'onSliderChange' && args is Map) {
            onSliderChange?.call(args);
          } else if (method == 'onSliderChanging' && args is Map) {
            onSliderChanging?.call(args);
          }
        },
      ),
    );
  }
}
