part of 'mpkit.dart';

enum MPPickerMode {
  selector,
  multiSelector,
  date,
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
    List<PickerItem>? items,
    String? headerText,
    MPPickerMode? mode,
    bool? disabled,
    String? start,
    String? end,
    List? defaultValue,
    MPPickerController? controller,
    this.onChangeCallback,
  }) : super(
          viewType: 'mp_picker',
          viewAttributes: {
            'items': items,
            'headerText': headerText,
            'mode': mode?.toString(),
            'disabled': disabled,
            'start': start,
            'end': end,
            'defaultValue': defaultValue,
          }..removeWhere((key, value) => value == null),
          child: child,
          controller: controller,
        ) {
    if (onChangeCallback != null) {
      assert(
        controller != null,
        'You need to set MPPicker.controller',
      );
    }
    controller?._host = this;
  }
}
