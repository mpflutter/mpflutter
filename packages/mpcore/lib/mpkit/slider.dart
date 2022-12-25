part of 'mpkit.dart';

class MPSliderController extends MPPlatformViewController with ChangeNotifier {
  MPSliderController({double? currentValue}) {
    _currentValue = currentValue ?? 0.0;
  }

  var _currentValue = 0.0;

  double get currentValue => _currentValue;

  void setValue(double value) {
    _currentValue = value;
    invokeMethod('setValue', params: {'value': value});
  }

  void _notify() {
    notifyListeners();
  }
}

class MPSlider extends StatelessWidget {
  final double min;
  final double max;
  final double step;
  final bool disabled;
  final double width;
  final double? defaultValue;
  final Function(double)? onValueChanged;
  final MPSliderController? controller;

  const MPSlider({
    this.min = 0.0,
    this.max = 100.0,
    this.step = 1.0,
    this.disabled = false,
    this.width = 300.0,
    this.defaultValue,
    this.onValueChanged,
    this.controller,
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
          'defaultValue': defaultValue ?? controller?.currentValue,
        }..removeWhere((key, value) => value == null),
        onMethodCall: (method, args) {
          if (method == 'onValueChanged' &&
              args is Map &&
              args['value'] is num) {
            controller?._currentValue = (args['value'] as num).toDouble();
            controller?._notify();
            onValueChanged?.call((args['value'] as num).toDouble());
          }
        },
        controller: controller,
      ),
    );
  }
}
