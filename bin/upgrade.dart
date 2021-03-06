part of 'mpflutter.dart';

void upgrade(List<String> args) {
  Process.runSync('pub', ['global', 'deactivate', 'mpflutter']);
  Process.runSync('pub', [
    'global',
    'activate',
    '--source',
    'git',
    '${codeSource}/mpflutter/mpflutter.git'
  ]);
  final upgradeResult =
      Process.runSync('flutter', ['packages', 'upgrade', '--offline']);
  print(upgradeResult.stdout);
  print(upgradeResult.stderr);
  _upgradeWeb();
  _upgradeTaro();
}

void _upgradeWeb() {
  try {
    Directory(path.join(
      Platform.isWindows ? 'C:' : '/',
      'tmp',
      '.mp_web_runtime',
    )).deleteSync(recursive: true);
  } catch (e) {}
  final gitCloneResult = Process.runSync(
    'git',
    [
      'clone',
      '-b',
      'stable',
      '${codeSource}/mpflutter/mp_web_runtime.git',
      path.join(
        Platform.isWindows ? 'C:' : '/',
        'tmp',
        '.mp_web_runtime',
      ),
      '--depth=1'
    ],
    runInShell: true,
  );
  print(gitCloneResult.stdout);
  print(gitCloneResult.stderr);
  Directory(path.join('web')).deleteSync(recursive: true);
  copyPathSync(
    path.join(
      Platform.isWindows ? 'C:' : '/',
      'tmp',
      '.mp_web_runtime',
      'dist',
    ),
    path.join('web'),
  );
}

void _upgradeTaro() {
  if (Directory(path.join(
    Platform.isWindows ? 'C:' : '/',
    'tmp',
    '.mp_taro_runtime',
  )).existsSync()) {
    Directory(path.join(
      Platform.isWindows ? 'C:' : '/',
      'tmp',
      '.mp_taro_runtime',
    )).deleteSync(recursive: true);
  }
}
