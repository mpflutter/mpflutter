import 'package:flutter/widgets.dart';
import 'package:mpcore/mpkit/mpkit.dart';

class WechatMiniProgramPickerController extends MPPlatformViewController {
  WechatMiniProgramPicker? _host;

  @override
  Future? onMethodCall(String method, Map? params) {
    if (method == 'onPickerCallback') {
      _host?.onPickerCallback?.call(params ?? {});
      print(params);
    }
    return super.onMethodCall(method, params);
  }
}

class WechatMiniProgramPicker extends MPPlatformView {
  final Function(Map)? onPickerCallback;

  WechatMiniProgramPicker({
    required Widget child,
    String? headerText,
    String? mode,
    bool? disabled,
    WechatMiniProgramPickerController? controller,
    this.onPickerCallback,
  }) : super(
          viewType: 'wechat_miniprogram_picker',
          viewAttributes: {
            'headerText': headerText,
            'mode': mode,
            'disabled': disabled,
          }..removeWhere((key, value) => value == null),
          child: child,
          controller: controller,
        ) {
    if (onPickerCallback != null) {
      assert(
        controller != null,
        'You need to set WechatMiniProgramPicker.controller',
      );
    }
    controller?._host = this;
  }
}
