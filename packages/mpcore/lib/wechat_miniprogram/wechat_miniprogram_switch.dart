import 'package:mpcore/mpkit/mpkit.dart';

class WechatMiniProgramSwitchController extends MPPlatformViewController {
  WechatMiniProgramSwitch? _host;

  @override
  Future? onMethodCall(String method, Map? params) {
    if (method == 'onCallback') {
      _host?.onCallback?.call(params ?? {});
      print(params);
    }
    return super.onMethodCall(method, params);
  }
}

class WechatMiniProgramSwitch extends MPPlatformView {
  final Function(Map)? onCallback;

  /// param type - switch, checkbox default switch
  WechatMiniProgramSwitch({
    bool? checked,
    bool? disabled,
    String? type,
    String? color,
    WechatMiniProgramSwitchController? controller,
    this.onCallback,
  }) : super(
          viewType: 'wechat_miniprogram_switch',
          viewAttributes: {
            'checked': checked,
            'disabled': disabled,
            'type': type,
            'color': color,
          }..removeWhere((key, value) => value == null),
          controller: controller,
        ) {
    if (onCallback != null) {
      assert(controller != null,
          'You need to set WechatMiniProgramSwitchController.controller');
    }
    controller?._host = this;
  }
}
