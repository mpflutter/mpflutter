import 'package:flutter/widgets.dart';
import 'package:mpcore/mpkit/mpkit.dart';

class WechatMiniProgramButtonController extends MPPlatformViewController {
  WechatMiniProgramButton? _host;

  @override
  Future? onMethodCall(String method, Map? params) {
    if (method == 'onButtonCallback') {
      _host?.onButtonCallback?.call(params ?? {});
      print(params);
    }
    return super.onMethodCall(method, params);
  }
}

class WechatMiniProgramButton extends MPPlatformView {
  final Function(Map)? onButtonCallback;

  WechatMiniProgramButton({
    required Widget child,
    String? openType,
    String? appParameter,
    WechatMiniProgramButtonController? controller,
    this.onButtonCallback,
  }) : super(
          viewType: 'wechat_miniprogram_button',
          viewAttributes: {
            'openType': openType,
            'appParameter': appParameter,
          }..removeWhere((key, value) => value == null),
          child: child,
          controller: controller,
        ) {
    if (onButtonCallback != null) {
      assert(controller != null,
          'You need to set WechatMiniProgramButton.controller');
    }
    controller?._host = this;
  }
}
