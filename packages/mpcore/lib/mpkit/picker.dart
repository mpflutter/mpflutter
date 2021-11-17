part of 'mpkit.dart';

enum MPPickerMode {
  selector,
  multiSelector,
  time,
  date,
  region,
}

class MPPickerController extends MPPlatformViewController {
  MPPicker? _host;

  @override
  Future? onMethodCall(String method, Map? params) {
    if (method == 'onChangeCallback') {
      _host?.onChangeCallback?.call(params ?? {});
    }
    return super.onMethodCall(method, params);
  }
}

class MPPicker extends MPPlatformView {
  final Function(Map)? onChangeCallback;

  MPPicker({
    required Widget child,
    String? headerText,
    MPPickerMode? mode,
    bool? disabled,
    MPPickerController? controller,
    this.onChangeCallback,
  }) : super(
          viewType: "mp_picker",
          viewAttributes: {
            'headerText': headerText,
            'mode': mode?.toString(),
            'disabled': disabled,
          }..removeWhere((key, value) => value == null),
          child: child,
          controller: controller,
        ) {
    // if (MPEnv.envHost() == MPEnvHostType.browser) {
    //   child = GestureDetector(
    //     onTap: () async {
    //       final result = await MPAction(
    //         type: 'web_dialogs',
    //         params: {
    //           'dialogType': 'picker',
    //           'title': 'title',
    //           'items': [
    //             PickerItem(label: '飞机票'),
    //             PickerItem(label: '火车票'),
    //             PickerItem(label: '的士票'),
    //             PickerItem(label: '公交票 (disabled)', disabled: true),
    //             PickerItem(label: '其他'),
    //           ],
    //           'confirmText': 'confirmText',
    //         },
    //       ).send();
    //       final _ = controller?.onMethodCall('onChangeCallback', result);
    //     },
    //     child: child,
    //   );
    // }
    if (onChangeCallback != null) {
      assert(
        controller != null,
        'You need to set MPPicker.controller',
      );
    }
    controller?._host = this;
  }
}
