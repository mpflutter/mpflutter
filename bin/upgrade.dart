import 'dart:io';
import 'package:path/path.dart' as path;

void upgrade(List<String> args) {
  Process.run('flutter', ['packages', 'upgrade']);
  _upgradeWeb();
}

void _upgradeWeb() {
  try {
    Directory(path.join('/', 'tmp', '.mp_client_web'))
        .deleteSync(recursive: true);
  } catch (e) {}
  Process.runSync('git', [
    'clone',
    'https://github.com/mpflutter/mp_client_web.git',
    '/tmp/.mp_client_web'
  ]);
  Directory(path.join('web')).deleteSync(recursive: true);
  Directory(path.join('web')).createSync();
  Directory(path.join('/', 'tmp', '.mp_client_web', 'dist'))
      .listSync()
      .forEach((element) {
    (element as File).copySync(
      path.join('web', path.basename(element.path)),
    );
  });
}
