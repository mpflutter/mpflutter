part of 'mpflutter.dart';

void _cloneTaro() {
  if (!Directory(path.join('/', 'tmp', '.mp_taro_runtime')).existsSync()) {
    Process.runSync('git', [
      'clone',
      'https://github.com/mpflutter/mp_taro_runtime.git',
      '/tmp/.mp_taro_runtime',
      '--depth=1'
    ]);
    Process.runSync('npm', ['i'], workingDirectory: '/tmp/.mp_taro_runtime');
  } else {
    Process.runSync(
      'git',
      ['reset', '--hard'],
      workingDirectory: '/tmp/.mp_taro_runtime',
    );
    Process.runSync(
      'git',
      ['clean', '-fd'],
      workingDirectory: '/tmp/.mp_taro_runtime',
    );
  }
}

void _buildTaro(String appType) {
  _cloneTaro();
  _clearWorkspace();

  Process.runSync('dart2js', [
    'lib/main.dart',
    '-O4',
    '--csp',
    '-Ddart.vm.product=true',
    '-Dmpcore.env.taro=true',
    '-o',
    '/tmp/weapp.dart.js',
  ]);

  var dartCode = File('/tmp/weapp.dart.js').readAsStringSync();
  dartCode =
      '''let document = undefined;let navigator = undefined;let window = flutterWindow;let self = flutterWindow;\n\n''' +
          dartCode;
  File('/tmp/.mp_taro_runtime/src/dart/main.dart.js')
      .writeAsStringSync(dartCode);

  var appConfig = File(path.join('taro', 'app.config.ts')).readAsStringSync();
  appConfig = appConfig.replaceAll('isDebug: true', 'isDebug: false');
  File('/tmp/.mp_taro_runtime/src/app.config.ts').writeAsStringSync(appConfig);

  var projectConfig =
      File(path.join('taro', 'project.config.json')).readAsStringSync();
  File('/tmp/.mp_taro_runtime/project.config.json')
      .writeAsStringSync(projectConfig);

  Process.runSync('npm', ['run', 'build:${appType}'],
      workingDirectory: '/tmp/.mp_taro_runtime');

  copyPathSync('/tmp/.mp_taro_runtime/dist', path.join('build', appType));
}

void _buildTaroDebug(String appType) async {
  _cloneTaro();
  _clearWorkspace();

  Process.runSync('dart2js', [
    'lib/main.dart',
    '-O4',
    '--csp',
    '-Ddart.vm.product=true',
    '-Dmpcore.env.taro=true',
    '-o',
    '/tmp/weapp.dart.js',
  ]);

  var dartCode =
      '''let document = undefined;let navigator = undefined;let window = flutterWindow;let self = flutterWindow;\n\n''';
  File('/tmp/.mp_taro_runtime/src/dart/main.dart.js')
      .writeAsStringSync(dartCode);

  var appConfig = File(path.join('taro', 'app.config.ts')).readAsStringSync();
  appConfig = appConfig.replaceAll('isDebug: false', 'isDebug: true');
  if (appConfig.contains('debugServer: "127.0.0.1"')) {
    appConfig = appConfig.replaceAll(
        'debugServer: "127.0.0.1"',
        await (() async {
          final localIPs =
              await NetworkInterface.list(type: InternetAddressType.IPv4);
          return 'debugServer: "${localIPs.first.addresses.first.address}"';
        })());
  }
  File('/tmp/.mp_taro_runtime/src/app.config.ts').writeAsStringSync(appConfig);

  var projectConfig =
      File(path.join('taro', 'project.config.json')).readAsStringSync();
  File('/tmp/.mp_taro_runtime/project.config.json')
      .writeAsStringSync(projectConfig);

  Process.runSync('npm', ['run', 'build:${appType}'],
      workingDirectory: '/tmp/.mp_taro_runtime');

  copyPathSync('/tmp/.mp_taro_runtime/dist', path.join('build', appType));
}
