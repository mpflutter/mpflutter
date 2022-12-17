import 'dart:io';
import 'package:mp_build_tools/i18n.dart';
import 'package:path/path.dart' as p;

void main(List<String> args) {
  print('git clone https://github.com/mpflutter/mpflutter_flutter_template');
  final gitCloneResult = Process.runSync('git', [
    'clone',
    'https://github.com/mpflutter/mpflutter_flutter_template',
    './flutter_native'
  ]);
  if (gitCloneResult.exitCode != 0) {
    print(gitCloneResult.stdout);
    print(gitCloneResult.stderr);
    throw I18n.executeFail('git clone');
  }
  Directory(p.join('flutter_native', '.git')).deleteSync(recursive: true);
  File(p.join('scripts', 'build_flutter_native.dart')).writeAsStringSync('''
import 'package:mp_build_tools/build_flutter_native.dart' as builder;

main(List<String> args) {
  builder.main(args);
}
''');
  print(I18n.flutterNativeCreated());
}
