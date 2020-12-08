part of 'mpflutter.dart';

void build(List<String> args) {
  try {
    Directory(path.join('build')).deleteSync(recursive: true);
  } catch (e) {}
  Directory(path.join('build')).createSync();
  Directory(path.join('build', 'web')).createSync();
  Process.runSync('dart2js', [
    'lib/main.dart',
    '-O4',
    '-o',
    'build/web/main.dart.js',
  ]);
  Process.runSync('flutter', [
    'build',
    'bundle',
  ]);
  Process.runSync('cp', [
    '-rf',
    './build/flutter_assets/assets',
    './build/web/assets',
  ]);
  Directory(path.join('web')).listSync().forEach((element) {
    (element as File).copySync(
      path.join('build', 'web', path.basename(element.path)),
    );
  });
}
