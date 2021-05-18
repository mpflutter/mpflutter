part of 'mpflutter.dart';

void _buildWeb() {
  _clearWorkspace();
  copyPathSync(path.join('web'), path.join('build', 'web'));
  Directory(path.join('build', 'web', 'assets')).createSync();
  _buildPlugin();
  subPackages().forEach((pkg) {
    if (pkg is String) {
      _buildWebPackage(pkg);
    } else if (pkg is YamlMap) {
      _buildWebPackage(pkg.keys.first);
    }
  });
  _buildWebAssets();
  _buildWebPlugins();
}

void _buildWebPackage(String pkgName) {
  final dart2JSResult = Process.runSync(
    'dart2js',
    [
      'lib/${pkgName}.dart',
      (() {
        if (processArgs.contains('-O0')) {
          return '-O0';
        }
        if (processArgs.contains('-O1')) {
          return '-O1';
        }
        if (processArgs.contains('-O2')) {
          return '-O2';
        }
        if (processArgs.contains('-O3')) {
          return '-O3';
        } else {
          return '-O4';
        }
      })(),
      '-Ddart.vm.product=true',
      '-o',
      'build/web/${pkgName}.dart.js',
    ],
    runInShell: Platform.isWindows ? true : false,
  );
  print(dart2JSResult.stdout);
  print(dart2JSResult.stderr);
  final fileHash = md5
      .convert(File('./build/web/${pkgName}.dart.js').readAsBytesSync())
      .toString()
      .substring(0, 6)
      .toLowerCase();
  File('./build/web/${pkgName}.dart.js')
      .renameSync('./build/web/${pkgName}.dart.${fileHash}.js');
  if (pkgName == 'main') {
    File('./build/web/index.html').writeAsStringSync(File('./web/index.html')
        .readAsStringSync()
        .replaceFirst('main.dart.js', '${pkgName}.dart.${fileHash}.js'));
  } else {
    File('./build/web/${pkgName}.html').writeAsStringSync(
        File('./web/index.html')
            .readAsStringSync()
            .replaceFirst('main.dart.js', '${pkgName}.dart.${fileHash}.js'));
  }
}

void _buildWebAssets() {
  final result = Process.runSync(
    'flutter',
    [
      'build',
      'bundle',
    ],
    runInShell: Platform.isWindows ? true : false,
  );
  print(result.stdout);
  print(result.stderr);
  if (Directory(path.join('build', 'flutter_assets', 'assets')).existsSync()) {
    copyPathSync(
      path.join('build', 'flutter_assets', 'assets'),
      path.join('build', 'web', 'assets', 'assets'),
    );
  }
}

void _buildWebPlugins() {
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
