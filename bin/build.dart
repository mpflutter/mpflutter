part of 'mpflutter.dart';

void build(List<String> args) {
  final target = args.length <= 1 || args[1] == 'web' ? 'web' : args[1];
  if (target == 'web') {
    _buildWeb();
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
    '-o',
    'build/web/main.dart.js',
  ]);
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
