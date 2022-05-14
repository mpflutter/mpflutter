part of '../mpcore.dart';

MPElement _encodeEditableText(Element element) {
  final widget = element.widget as EditableText;
  var mpWidget = widget is MPEditableText ? widget : null;
  if (mpWidget != null) {
    final focusNode = mpWidget.focusNode;
    focusNode.lastEventListener = () {
      if (focusNode.lastEvent != null) {
        MPChannel.postMessage(
          json.encode({
            'type': 'editable_text',
            'message': {
              'target': element.hashCode,
              'event': focusNode.lastEvent,
            },
          }),
          forLastConnection: true,
        );
        focusNode.lastEvent = null;
      }
    };
  }
  return MPElement(
    hashCode: element.hashCode,
    flutterElement: element,
    name: 'editable_text',
    children: [],
    attributes: {
      'style': _encodeTextStyle(widget.style),
      'value': widget.controller.text,
      'maxLength': mpWidget?.maxLength,
      'placeholder': mpWidget?.placeholder,
      'placeholderStyle': mpWidget?.placeholderStyle != null
          ? _encodeTextStyle(mpWidget!.placeholderStyle!)
          : null,
      'maxLines': widget.maxLines,
      'obscureText': widget.obscureText,
      'readOnly': widget.readOnly,
      'textAlign': widget.textAlign.toString(),
      'autofocus': widget.autofocus,
      'autocorrect': widget.autocorrect,
      'enableSuggestions': widget.enableSuggestions,
      'keyboardType': widget.keyboardType.toString(),
      'textInputAction': widget.textInputAction.toString(),
      'onSubmitted': widget.onSubmitted != null ? element.hashCode : null,
      'onChanged': element.hashCode,
    },
  );
}
