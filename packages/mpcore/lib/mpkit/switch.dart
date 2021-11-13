part of 'mpkit.dart';

class MPSwitchController extends MPPlatformViewController {
  MPSwitch? _host;

  @override
  Future? onMethodCall(String method, Map? params) {
    if (method == 'onCallback') {
      _host?.onCallback?.call(params ?? {});
      print(params);
    }
    return super.onMethodCall(method, params);
  }
}

class MPSwitch extends MPPlatformView {
  final Function(Map)? onCallback;

  /// param type - switch, checkbox default switch
  MPSwitch({
    bool? checked,
    bool? disabled,
    String? type,
    String? color,
    MPSwitchController? controller,
    this.onCallback,
  }) : super(
          viewType: 'mp_switch',
          viewAttributes: {
            'checked': checked,
            'disabled': disabled,
            'type': type,
            'color': color,
          }..removeWhere((key, value) => value == null),
          controller: controller,
        ) {
    if (onCallback != null) {
      assert(
          controller != null, 'You need to set MPSwitchController.controller');
    }
    controller?._host = this;
  }
}
