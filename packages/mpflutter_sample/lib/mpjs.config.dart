import 'dart:convert';

const isMiniProgram = bool.fromEnvironment(
  'isMiniProgram',
  defaultValue: false,
);

const isWeb = bool.fromEnvironment(
  'isWeb',
  defaultValue: false,
);

final templates = {
  'foo': isMiniProgram
      ? '''function(arg0) {
    wx.showModal({title: 'alert', content: (new Date()).toString()});
    return 'foo result: ' + arg0;
  }
  '''
      : '''function(arg0) {
    alert(new Date().toString());
    return 'foo result: ' + arg0;
  }''',
};

void main(List<String> args) {
  print(json.encode(templates));
}
