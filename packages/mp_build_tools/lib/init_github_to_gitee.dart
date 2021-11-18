// https://github.com/mpflutter/

import 'dart:io';

void main(List<String> args) {
  if (File('pubspec.yaml').existsSync()) {
    var code = File('pubspec.yaml').readAsStringSync();
    code = code.replaceAll(
        'https://github.com/mpflutter/', 'https://gitee.com/mpflutter/');
    File('pubspec.yaml').writeAsStringSync(code);
  }
  if (File('pubspec.lock').existsSync()) {
    var code = File('pubspec.lock').readAsStringSync();
    code = code.replaceAll(
        'https://github.com/mpflutter/', 'https://gitee.com/mpflutter/');
    File('pubspec.lock').writeAsStringSync(code);
  }
}
