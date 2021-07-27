part of '../mpcore.dart';

MPElement _encodeEditableText(Element element) {
  final widget = element.widget as EditableText;
  return MPElement(
    hashCode: element.hashCode,
    flutterElement: element,
    name: 'editable_text',
    children: [],
    // ignore: invalid_use_of_protected_member
    constraints: element.findRenderObject()?.constraints,
    attributes: {
      'style': _encodeTextStyle(widget.style),
      'value':
          widget.controller.textDirty == true ? widget.controller.text : null,
      'placeholder': widget.placeholder,
      'maxLines': widget.maxLines,
      'obscureText': widget.obscureText,
      'readOnly': widget.readOnly,
      'textAlign': widget.textAlign.toString(),
      'autofocus': widget.autofocus,
      'autocorrect': widget.autocorrect,
      'enableSuggestions': widget.enableSuggestions,
      'keyboardType': widget.keyboardType.toString(),
      'onSubmitted': widget.onSubmitted != null ? element.hashCode : null,
      'onChanged': element.hashCode,
    },
  );
}
