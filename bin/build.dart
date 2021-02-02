part of 'mpflutter.dart';

void build(List<String> args) {
  final target = args.length <= 1 || args[1] == 'web' ? 'web' : args[1];
  final isDebug = args.length > 2 && args[2] == '--debug';
  if (target == 'web') {
    _buildWeb();
  } else if (target == 'weapp') {
    if (isDebug) {
      _buildTaroDebug("weapp");
    } else {
      _buildTaro("weapp");
    }
  }
}

void _buildWeb() {
  try {
    Directory(path.join('build')).deleteSync(recursive: true);
  } catch (e) {}
  Directory(path.join('build')).createSync();
  copyPathSync(path.join('web'), path.join('build', 'web'));
  if (File('lib/generated_plugin_registrant.dart').existsSync()) {
    final code = File('lib/generated_plugin_registrant.dart')
        .readAsStringSync()
        .replaceFirst("import 'dart:ui';", '');
    File('lib/generated_plugin_registrant.dart').writeAsStringSync(code);
  }
  Process.runSync('dart2js', [
    'lib/main.dart',
    '-O4',
    '-Ddart.vm.product=true',
    '-o',
    'build/web/main.dart.js',
  ]);
  // Add hash to main.dart.js {
  final mainDartJSHash = md5
      .convert(File('./build/web/main.dart.js').readAsBytesSync())
      .toString()
      .substring(0, 6)
      .toLowerCase();
  File('./build/web/main.dart.js')
      .renameSync('./build/web/main.dart.${mainDartJSHash}.js');
  File('./build/web/index.html').writeAsStringSync(
      File('./build/web/index.html')
          .readAsStringSync()
          .replaceFirst('main.dart.js', 'main.dart.${mainDartJSHash}.js'));
  // } Add hash to main.dart.js
  Process.runSync('flutter', [
    'build',
    'bundle',
  ]);
  if (Directory(path.join('build', 'flutter_assets', 'assets')).existsSync()) {
    Directory(path.join('build', 'web', 'assets')).createSync();
    copyPathSync(
      path.join('build', 'flutter_assets', 'assets'),
      path.join('build', 'web', 'assets', 'assets'),
    );
  } else {
    Directory(path.join('build', 'web', 'assets')).createSync();
  }
  final pluginJSBuffer = StringBuffer();
  final pluginCSSBuffer = StringBuffer();
  final lines = File('./.packages').readAsLinesSync();
  for (final line in lines) {
    final pkgPath = line
        .replaceFirst(RegExp('.*?:'), '')
        .replaceFirst('file://', '')
        .replaceFirst('/lib/', '');
    if (File('$pkgPath/web/dist/index.min.js').existsSync()) {
      pluginJSBuffer
          .writeln(File('$pkgPath/web/dist/index.min.js').readAsStringSync());
    }
    if (File('$pkgPath/web/dist/index.css').existsSync()) {
      pluginCSSBuffer
          .writeln(File('$pkgPath/web/dist/index.css').readAsStringSync());
    }
  }
  File(path.join('build', 'web', 'assets', 'mp_plugins.js'))
      .writeAsStringSync(pluginJSBuffer.toString());
  File(path.join('build', 'web', 'assets', 'mp_plugins.css'))
      .writeAsStringSync(pluginCSSBuffer.toString());
}

void _buildTaro(String appType) {
  if (!Directory(path.join('/', 'tmp', '.mp_taro_runtime')).existsSync()) {
    Process.runSync('git', [
      'clone',
      'https://github.com/mpflutter/mp_taro_runtime.git',
      '/tmp/.mp_taro_runtime',
      '--depth=1'
    ]);
    Process.runSync('npm', ['i'], workingDirectory: '/tmp/.mp_taro_runtime');
  }

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

  try {
    Directory(path.join('build')).deleteSync(recursive: true);
  } catch (e) {}
  Directory(path.join('build')).createSync();
  copyPathSync('/tmp/.mp_taro_runtime/dist', path.join('build', appType));
}

void _buildTaroDebug(String appType) async {
  if (!Directory(path.join('/', 'tmp', '.mp_taro_runtime')).existsSync()) {
    Process.runSync('git', [
      'clone',
      'https://github.com/mpflutter/mp_taro_runtime.git',
      '/tmp/.mp_taro_runtime',
      '--depth=1'
    ]);
    Process.runSync('npm', ['i'], workingDirectory: '/tmp/.mp_taro_runtime');
  }

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

  try {
    Directory(path.join('build')).deleteSync(recursive: true);
  } catch (e) {}
  Directory(path.join('build')).createSync();
  copyPathSync('/tmp/.mp_taro_runtime/dist', path.join('build', appType));
}
