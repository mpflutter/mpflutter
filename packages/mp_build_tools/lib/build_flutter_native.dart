import 'dart:io';
import 'package:mp_build_tools/i18n.dart';
import 'package:path/path.dart' as p;
import 'build_mpk.dart' as build_mpk;

void main(List<String> args) async {
  if (!Directory(p.join('flutter_native')).existsSync()) {
    throw I18n.flutterNativeProjectNotExists();
  }
  await build_mpk.main(args);
  Directory(p.join('build')).listSync().forEach((element) {
    if (element.path.endsWith('.mpk')) {
      return;
    }
    element.deleteSync(recursive: true);
  });
  _copyPathSync(p.join('flutter_native'), p.join('build'));
  File(p.join('build', 'app.mpk'))
      .renameSync(p.join('build', 'assets', 'app.mpk'));
  File(p.join('build', 'lib', 'mp_config.dart')).writeAsStringSync('''
class MPConfig {
  static const String devServer = "127.0.0.1";
  static const bool dev = false;
}
''');
  print(I18n.flutterNativeBuildSuccess());
}

void _copyPathSync(String from, String to) {
  Directory(to).createSync(recursive: true);
  for (final file in Directory(from).listSync(recursive: true)) {
    final copyTo = p.join(to, p.relative(file.path, from: from));
    if (file is Directory) {
      Directory(copyTo).createSync(recursive: true);
    } else if (file is File) {
      File(file.path).copySync(copyTo);
    } else if (file is Link) {
      Link(copyTo).createSync(file.targetSync(), recursive: true);
    }
  }
}
