part of 'mpflutter.dart';

void upgrade(List<String> args) {
  Process.run('flutter', ['packages', 'upgrade']);
  _upgradeWeb();
}

void _upgradeWeb() {
  try {
    Directory(path.join('/', 'tmp', '.mp_web_runtime'))
        .deleteSync(recursive: true);
  } catch (e) {}
  Process.runSync('git', [
    'clone',
    'https://github.com/mpflutter/mp_web_runtime.git',
    '/tmp/.mp_web_runtime'
  ]);
  Directory(path.join('web')).deleteSync(recursive: true);
  copyPathSync(
    path.join('/', 'tmp', '.mp_web_runtime', 'dist'),
    path.join('web'),
  );
}
