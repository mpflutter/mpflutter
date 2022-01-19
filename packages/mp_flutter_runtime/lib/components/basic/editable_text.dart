part of '../../mp_flutter_runtime.dart';

class _EditableText extends ComponentView {
  _EditableText({
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
  Widget builder(BuildContext context) {
    return _EditableTextContent(
      style: getValueFromAttributes(context, 'style'),
      maxLines: getIntFromAttributes(context, 'maxLines') ?? 1,
      obscureText: getBoolFromAttributes(context, 'obscureText') ?? false,
      readOnly: getBoolFromAttributes(context, 'readOnly') ?? false,
      placeholder: getStringFromAttributes(context, 'placeholder'),
      height: getSize().height,
      defaultValue: getStringFromAttributes(context, 'value'),
      keyboardType: (() {
        final value = getStringFromAttributes(context, 'keyboardType');
        if (value is String) {
          switch (value) {
            case 'TextInputType.text':
              return TextInputType.text;
            case 'TextInputType.multiline':
              return TextInputType.multiline;
            case 'TextInputType.number':
              return TextInputType.number;
            case 'TextInputType.phone':
              return TextInputType.phone;
            case 'TextInputType.datetime':
              return TextInputType.datetime;
            case 'TextInputType.emailAddress':
              return TextInputType.emailAddress;
            case 'TextInputType.url':
              return TextInputType.url;
            case 'TextInputType.visiblePassword':
              return TextInputType.visiblePassword;
            case 'TextInputType.name':
              return TextInputType.name;
            case 'TextInputType.streetAddress':
              return TextInputType.streetAddress;
          }
        }
        return null;
      })(),
      autofocus: getBoolFromAttributes(context, 'autofocus') ?? false,
      autoCorrect: getBoolFromAttributes(context, 'autoCorrect') ?? false,
      onSubmitted: (value) {
        componentFactory.engine._sendMessage({
          "type": "editable_text",
          "message": {
            "event": "onSubmitted",
            "target": dataHashCode,
            "data": value,
          },
        });
      },
      onChanged: (value) {
        componentFactory.engine._sendMessage({
          "type": "editable_text",
          "message": {
            "event": "onChanged",
            "target": dataHashCode,
            "data": value,
          },
        });
      },
    );
  }
}

class _EditableTextContent extends StatefulWidget {
  final Map? style;
  final int maxLines;
  final bool obscureText;
  final bool readOnly;
  final String? placeholder;
  final double height;
  final String? defaultValue;
  final Function(String) onSubmitted;
  final Function(String) onChanged;
  final TextInputType? keyboardType;
  final bool autofocus;
  final bool autoCorrect;

  const _EditableTextContent({
    Key? key,
    this.style,
    required this.maxLines,
    required this.obscureText,
    required this.readOnly,
    this.placeholder,
    required this.height,
    this.defaultValue,
    required this.onSubmitted,
    required this.onChanged,
    this.keyboardType,
    required this.autofocus,
    required this.autoCorrect,
  }) : super(key: key);

  @override
  __EditableTextContentState createState() => __EditableTextContentState();
}

class __EditableTextContentState extends State<_EditableTextContent> {
  final editingController = TextEditingController();
  final focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    editingController.text = widget.defaultValue ?? '';
  }

  @override
  void didUpdateWidget(_EditableTextContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.defaultValue != widget.defaultValue) {
      editingController.text = widget.defaultValue ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: editingController,
      focusNode: focusNode,
      style: _RichText.textStyleFromData(widget.style),
      maxLines: widget.maxLines,
      obscureText: widget.obscureText,
      readOnly: widget.readOnly,
      keyboardType: widget.keyboardType,
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: widget.placeholder,
        contentPadding: EdgeInsets.only(
          bottom: widget.height < 54.0 ? (54.0 - widget.height) / 2.0 : 0.0,
        ),
      ),
      autofocus: widget.autofocus,
      autocorrect: widget.autoCorrect,
      onSubmitted: (value) {
        widget.onSubmitted(value);
      },
      onChanged: (value) {
        widget.onChanged(value);
      },
    );
  }
}
