part of 'mpkit.dart';

class MPSliderController extends MPPlatformViewController {
  MPSlider? _host;

  @override
  Future? onMethodCall(String method, Map? params) {
    if (method == 'onSliderChange') {
      _host?.onSliderChange?.call(params ?? {});
    } else if (method == 'onSliderChanging') {
      _host?.onSliderChanging?.call(params ?? {});
    }
    return super.onMethodCall(method, params);
  }
}

class MPSlider extends MPPlatformView {
  final Function(Map)? onSliderChange;
  final Function(Map)? onSliderChanging;

  MPSlider({
    int? min,
    int? max,
    int? step,
    bool? disabled,
    int? value,
    Color? activeColor,
    Color? backgroundColor,
    int? blockSize,
    Color? blockColor,
    bool? showValue,
    MPSliderController? controller,
    this.onSliderChange,
    this.onSliderChanging,
  }) : super(
          viewType: 'mp_slider',
          viewAttributes: {
            'min': min,
            'max': max,
            'step': step,
            'disabled': disabled,
            'value': value,
            'activeColor':
                activeColor == null ? null : activeColor.value.toString(),
            'backgroundColor': backgroundColor == null
                ? null
                : backgroundColor.value.toString(),
            'blockSize': blockSize,
            'blockColor':
                blockColor == null ? null : blockColor.value.toString(),
            'showValue': showValue,
          }..removeWhere((key, value) => value == null),
          controller: controller,
        ) {
    if (onSliderChange != null) {
      assert(
          controller != null, 'You need to set MPSliderController.controller');
    }
    if (onSliderChanging != null) {
      assert(
          controller != null, 'You need to set MPSliderController.controller');
    }
    controller?._host = this;
  }
}
