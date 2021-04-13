part of 'mpflutter.dart';

void _cloneTaro() {
  if (!Directory(path.join('/', 'tmp', '.mp_taro_runtime')).existsSync() ||
      !File(path.join('/', 'tmp', '.mp_taro_runtime', 'package.json'))
          .existsSync()) {
    try {
      Directory(path.join('/', 'tmp', '.mp_taro_runtime'))
          .deleteSync(recursive: true);
    } catch (e) {}
    final gitCloneResult = Process.runSync('git', [
      'clone',
      '-b',
      'stable',
      'https://github.com/mpflutter/mp_taro_runtime.git',
      '/tmp/.mp_taro_runtime',
      '--depth=1'
    ]);
    print(gitCloneResult.stdout);
    print(gitCloneResult.stderr);
    final npmIResult = Process.runSync('npm', ['i'],
        workingDirectory: '/tmp/.mp_taro_runtime');
    print(npmIResult.stdout);
    print(npmIResult.stderr);
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
  _copyPages();

  subPackages().forEach((pkg) {
    String pkgName;
    if (pkg is String) {
      pkgName = pkg;
    } else if (pkg is YamlMap) {
      pkgName = pkg.keys.first;
    }
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
      var appCode = File('/tmp/.mp_taro_runtime/src/components/app.tsx')
          .readAsStringSync();
      appCode = appCode.replaceAll('require("../dart/main.dart");',
          'require("../dart/${pkgName}.dart");');
      File('/tmp/.mp_taro_runtime/src/components/app_${pkgName}.tsx')
          .writeAsStringSync(appCode);
    }
  });

  var appConfig = File(path.join('taro', 'app.config.ts')).readAsStringSync();
  appConfig = appConfig.replaceAll('isDebug: true', 'isDebug: false');
  File('/tmp/.mp_taro_runtime/src/app.config.ts').writeAsStringSync(appConfig);

  var projectConfig =
      File(path.join('taro', 'project.config.json')).readAsStringSync();
  File('/tmp/.mp_taro_runtime/project.config.json')
      .writeAsStringSync(projectConfig);

  final npmRunBuildResult = Process.runSync(
    'npm',
    ['run', 'build:${appType}'],
    workingDirectory: '/tmp/.mp_taro_runtime',
  );

  print(npmRunBuildResult.stdout);
  print(npmRunBuildResult.stderr);

  copyPathSync('/tmp/.mp_taro_runtime/dist', path.join('build', appType));
}

void _copyPages() {
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
