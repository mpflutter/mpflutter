part of 'mpflutter.dart';

void _cloneTaro() {
  if (!Directory(path.join('/', 'tmp', '.mp_taro_runtime')).existsSync() ||
      !File(path.join('/', 'tmp', '.mp_taro_runtime', 'package.json'))
          .existsSync()) {
    try {
      Directory(path.join('/', 'tmp', '.mp_taro_runtime'))
          .deleteSync(recursive: true);
    } catch (e) {}
    final gitCloneResult = Process.runSync(
      'git',
      [
        'clone',
        '-b',
        'stable',
        '${codeSource}/mpflutter/mp_taro_runtime.git',
        '/tmp/.mp_taro_runtime',
        '--depth=1'
      ],
      runInShell: Platform.isWindows ? true : false,
    );
    print(gitCloneResult.stdout);
    print(gitCloneResult.stderr);
    final npmIResult = Process.runSync(
      'npm',
      ['i'],
      workingDirectory: '/tmp/.mp_taro_runtime',
      runInShell: Platform.isWindows ? true : false,
    );
    print(npmIResult.stdout);
    print(npmIResult.stderr);
  } else if (!processArgs.contains('--mpDev')) {
    Process.runSync(
      'git',
      ['reset', '--hard'],
      workingDirectory: '/tmp/.mp_taro_runtime',
      runInShell: Platform.isWindows ? true : false,
    );
    Process.runSync(
      'git',
      ['clean', '-fd'],
      workingDirectory: '/tmp/.mp_taro_runtime',
      runInShell: Platform.isWindows ? true : false,
    );
  }
}

void _buildTaro(String appType) async {
  _cloneTaro();
  _clearWorkspace();
  _copyTaroPages();
  _copyTaroScripts();

  var appConfig = File(path.join('taro', 'app.config.ts')).readAsStringSync();
  var projectConfig =
      File(path.join('taro', 'project.config.json')).readAsStringSync();

  subPackages().forEach((pkg) {
    String? pkgName;
    if (pkg is String) {
      pkgName = pkg;
    } else if (pkg is YamlMap) {
      pkgName = pkg.keys.first;
    }
    if (pkgName == null) throw "pkgName must not null.";
    final dart2jsResult = Process.runSync(
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
        '--csp',
        '-Ddart.vm.product=true',
        '-Dmpcore.env.taro=true',
        '-o',
        '/tmp/weapp.dart.js',
      ],
      runInShell: Platform.isWindows ? true : false,
    );
    print(dart2jsResult.stdout);
    print(dart2jsResult.stderr);
    var dartCode = File('/tmp/weapp.dart.js').readAsStringSync();
    dartCode =
        '''let document = undefined;let navigator = undefined;let window = flutterWindow;let self = flutterWindow;\n\n''' +
            dartCode;
    File('/tmp/.mp_taro_runtime/src/dart/${pkgName}.dart.js')
        .writeAsStringSync(dartCode);
    if (pkgName != 'main') {
      Directory('/tmp/.mp_taro_runtime/src/pages/${pkgName}').createSync();
      var indexCode = File('/tmp/.mp_taro_runtime/src/pages/index/index.tsx')
          .readAsStringSync();
      indexCode = indexCode.replaceAll(
          '"../../components/app"', '"../../components/app_${pkgName}"');
      File('/tmp/.mp_taro_runtime/src/pages/${pkgName}/index.tsx')
          .writeAsStringSync(indexCode);
      if (appConfig.contains('navigationStyle: "custom"')) {
        File('/tmp/.mp_taro_runtime/src/pages/${pkgName}/index.config.js')
            .writeAsStringSync('export default { navigationStyle: "custom" };');
      }
      var appCode = File('/tmp/.mp_taro_runtime/src/components/app.tsx')
          .readAsStringSync();
      appCode = appCode.replaceAll('require("../dart/main.dart");',
          'require("../dart/${pkgName}.dart");');
      File('/tmp/.mp_taro_runtime/src/components/app_${pkgName}.tsx')
          .writeAsStringSync(appCode);
    } else {
      if (appConfig.contains('navigationStyle: "custom"')) {
        File('/tmp/.mp_taro_runtime/src/pages/index/index.config.js')
            .writeAsStringSync('export default { navigationStyle: "custom" };');
      }
    }
  });

  if (processArgs.contains('--debug')) {
    appConfig = appConfig.replaceAll('isDebug: false', 'isDebug: true');
    final debugIP = await selectDebugIP();
    if (debugIP != null) {
      appConfig = appConfig.replaceAll(
          'debugServer: "127.0.0.1"', 'debugServer: "${debugIP}"');
    }
  } else {
    appConfig = appConfig.replaceAll('isDebug: true', 'isDebug: false');
  }
  File('/tmp/.mp_taro_runtime/src/app.config.ts').writeAsStringSync(appConfig);

  File('/tmp/.mp_taro_runtime/project.config.json')
      .writeAsStringSync(projectConfig);

  final npmRunBuildResult = Process.runSync(
    'npm',
    ['run', 'build:${appType}'],
    workingDirectory: '/tmp/.mp_taro_runtime',
    runInShell: Platform.isWindows ? true : false,
  );

  print(npmRunBuildResult.stdout);
  print(npmRunBuildResult.stderr);

  copyPathSync('/tmp/.mp_taro_runtime/dist', path.join('build', appType));

  if (appConfig.contains('assetsServer: null') ||
      appConfig.contains('assetsServer: undefined')) {
    _copyTaroAssets();
  }
}

void _copyTaroPages() {
  if (Directory('./taro/pages').existsSync()) {
    final dirs = Directory('./taro/pages').listSync();
    dirs.forEach((element) {
      if (element.statSync().type == FileSystemEntityType.directory) {
        copyPathSync(element.path,
            '/tmp/.mp_taro_runtime/src/pages/${element.path.split('/').last}');
      }
    });
  }
}

void _copyTaroAssets() {
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
      path.join('/', 'tmp', '.mp_taro_runtime', 'dist', 'assets'),
    );
  }
}

void _copyTaroScripts() {
  File('/tmp/.mp_taro_runtime/src/dart/hook.js').writeAsStringSync('');
  var files = Directory(path.join('taro')).listSync();
  files.where((element) => element.path.endsWith('.js')).forEach((element) {
    File(element.path).copySync(
        '/tmp/.mp_taro_runtime/src/dart/${element.path.split('/').last}');
  });
}
