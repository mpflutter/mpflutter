part of '../../mp_flutter_runtime.dart';

// ignore: must_be_immutable
class _MPSwitch extends MPPlatformView {
  __SwitchContentState? _contentState;

  _MPSwitch({
    Key? key,
    Map? data,
    Map? parentData,
    required _MPComponentFactory componentFactory,
  }) : super(
            key: key,
            data: data,
            parentData: parentData,
            componentFactory: componentFactory);

  @override
  Future onMethodCall(String method, dynamic params) async {
    if (method == 'setValue' && params is Map) {
      // ignore: invalid_use_of_protected_member
      _contentState?.setState(() {
        _contentState?.value = params['value'] as bool;
      });
    }
    return null;
  }

  @override
  Widget builder(BuildContext context) {
    return _SwitchContent(
      defaultValue: getBoolFromAttributes(context, 'defaultValue') ?? false,
      onValueChanged: (value) {
        invokeMethod('onValueChanged', {'value': value});
      },
    );
  }
}

class _SwitchContent extends StatefulWidget {
  final bool defaultValue;
  final Function(bool) onValueChanged;

  const _SwitchContent({
    Key? key,
    required this.defaultValue,
    required this.onValueChanged,
  }) : super(key: key);

  @override
  __SwitchContentState createState() => __SwitchContentState();
}

class __SwitchContentState extends State<_SwitchContent> {
  bool value = false;

  @override
  void initState() {
    super.initState();
    value = widget.defaultValue;
  }

  @override
  Widget build(BuildContext context) {
    context.findAncestorWidgetOfExactType<_MPSwitch>()?._contentState = this;
    return Switch(
      value: value,
      onChanged: (value) {
        setState(() {
          this.value = value;
        });
        widget.onValueChanged(value);
      },
    );
  }
}
