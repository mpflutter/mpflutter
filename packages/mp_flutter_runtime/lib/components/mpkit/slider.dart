part of '../../mp_flutter_runtime.dart';

// ignore: must_be_immutable
class _MPSlider extends MPPlatformView {
  __SliderContentState? _contentState;

  _MPSlider({
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
    // if (method == 'setValue' && params is Map) {
    //   // ignore: invalid_use_of_protected_member
    //   _contentState?.setState(() {
    //     _contentState?.value = params['value'] as bool;
    //   });
    // }
    return null;
  }

  @override
  Widget builder(BuildContext context) {
    return _SliderContent(
      min: getDoubleFromAttributes(context, 'min') ?? 0.0,
      max: getDoubleFromAttributes(context, 'max') ?? 1.0,
      step: getDoubleFromAttributes(context, 'step'),
      defaultValue: getDoubleFromAttributes(context, 'defaultValue') ?? 0.0,
      onValueChanged: (value) {
        invokeMethod('onValueChanged', {'value': value});
      },
    );
  }
}

class _SliderContent extends StatefulWidget {
  final double min;
  final double max;
  final double? step;
  final double defaultValue;
  final Function(double) onValueChanged;

  const _SliderContent({
    Key? key,
    required this.min,
    required this.max,
    required this.step,
    required this.defaultValue,
    required this.onValueChanged,
  }) : super(key: key);

  @override
  __SliderContentState createState() => __SliderContentState();
}

class __SliderContentState extends State<_SliderContent> {
  double value = 0.0;

  @override
  void initState() {
    super.initState();
    value = widget.defaultValue;
  }

  @override
  Widget build(BuildContext context) {
    context.findAncestorWidgetOfExactType<_MPSlider>()?._contentState = this;
    return Slider(
      min: widget.min,
      max: widget.max,
      value: value,
      onChanged: (value) {
        final step = widget.step;
        if (step != null) {
          value = (value / step).roundToDouble();
        }
        setState(() {
          this.value = value;
        });
        widget.onValueChanged(value);
      },
    );
  }
}
