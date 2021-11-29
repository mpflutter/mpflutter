part of 'mpkit.dart';

class MPSwitchController extends MPPlatformViewController with ChangeNotifier {
  MPSwitchController({bool? currentValue}) {
    _currentValue = currentValue ?? false;
  }

  var _currentValue = false;

  bool get currentValue => _currentValue;

  void setValue(bool value) {
    _currentValue = value;
    invokeMethod('setValue', params: {'value': value});
  }

  void _notify() {
    notifyListeners();
  }
}

class MPSwitch extends StatelessWidget {
  final bool? checked;
  final bool? disabled;
  final String? type;
  final String? color;
  final bool? defaultValue;
  final Function(bool)? onValueChanged;
  final MPSwitchController? controller;

  MPSwitch({
    this.checked,
    this.disabled,
    this.type,
    this.color,
    this.defaultValue,
    this.onValueChanged,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 28,
      child: MPPlatformView(
        viewType: 'mp_switch',
        viewAttributes: {
          'checked': checked,
          'disabled': disabled,
          'type': type,
          'color': color,
          'defaultValue': defaultValue ?? controller?.currentValue,
        }..removeWhere((key, value) => value == null),
        onMethodCall: (method, args) {
          if (method == 'onValueChanged' &&
              args is Map &&
              args['value'] is bool) {
            controller?._currentValue = args['value'] as bool;
            controller?._notify();
            onValueChanged?.call(args['value'] as bool);
          }
        },
        controller: controller,
      ),
    );
  }
}
