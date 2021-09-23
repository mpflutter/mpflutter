import 'package:flutter/widgets.dart';
import 'package:mpcore/mpkit/mpkit.dart';

class WechatMiniProgramButton extends MPPlatformView {
  WechatMiniProgramButton(
      {required Widget child, String? openType, String? appParameter})
      : super(
          viewType: 'wechat_miniprogram_button',
          viewAttributes: {
            'openType': openType,
            'appParameter': appParameter,
          }..removeWhere((key, value) => value == null),
          child: child,
        );
}
