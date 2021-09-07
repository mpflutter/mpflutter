import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:crypto/crypto.dart';

import 'build_plugins.dart' as plugin_builder;

main(List<String> args) {
  _checkPubspec();
  _createBuildDir();
  _buildDartJS(dumpInfo: args.contains('--dump-info'));
  plugin_builder.main(args);
  _copyWebSource();
}

_checkPubspec() {
  if (!File('pubspec.yaml').existsSync()) {
    throw '''
    The pubspec.yaml not exists, confirm you are in the mpflutter project root dir. [EN]
    pubspec.yaml 文件不存在，请确认您当前处于 mpflutter 工程根目录。[ZH]
    ''';
  }
}

_createBuildDir() {
  if (!Directory('build').existsSync()) {
    Directory('build').createSync();
  } else {
    Directory('build').deleteSync(recursive: true);
    Directory('build').createSync();
  }
}

void _buildDartJS({bool dumpInfo = false}) {
  final dart2JsResult = Process.runSync(
      'dart2js',
      [
        'lib/main.dart',
        '-O4',
        '-Ddart.vm.product=true',
        dumpInfo ? '--dump-info' : '',
        '-o',
        'build/main.dart.js'
      ]..removeWhere((element) => element.isEmpty),
      runInShell: true);
  if (dart2JsResult.exitCode != 0) {
    print(dart2JsResult.stdout);
    print(dart2JsResult.stderr);
    throw 'dart2js execute failed.';
  }
  _fixDefererLoader();
  final buildBundleResult = Process.runSync(
    'flutter',
    [
      'build',
      'bundle',
    ],
    runInShell: true,
  );
  if (buildBundleResult.exitCode != 0) {
    print(buildBundleResult.stdout);
    print(buildBundleResult.stderr);
    throw 'flutter build bundle execute failed.';
  }
  if (Directory('./build/flutter_assets').existsSync()) {
    Directory('./build/flutter_assets').renameSync('./build/assets');
  }
  _removeFiles([
    './build/assets/isolate_snapshot_data',
    './build/assets/kernel_blob.bin',
    './build/assets/vm_snapshot_data',
    './build/snapshot_blob.bin.d'
  ]);
}

_fixDefererLoader() {
  var code = File('build/main.dart.js').readAsStringSync();
  code = code.replaceAllMapped(RegExp(r"m=\$\.([a-z0-9A-Z]+)\(\)\nm.toString"),
      (match) {
    return "m=\$.${match.group(1)}() || ''\nm.toString";
  });
  code = code.replaceFirst(
      "\$.\$get\$thisScript();", "\$.\$get\$thisScript() || '';");
  File('build/main.dart.js').writeAsStringSync(code);
}

_copyWebSource() async {
  _copyPathSync('./web', './build');
  final mainDartJSHashCode = File('./build/main.dart.js').existsSync()
      ? (await md5.bind(File('./build/main.dart.js').openRead()).first)
          .toString()
          .substring(0, 8)
      : "";
  final pluginMinJSHashCode = File('./build/plugins.min.js').existsSync()
      ? (await md5.bind(File('./build/plugins.min.js').openRead()).first)
          .toString()
          .substring(0, 8)
      : "";
  var indexFileContent = File('./web/index.html').readAsStringSync();
  indexFileContent =
      indexFileContent.replaceAll("var dev = true;", "var dev = false;");
  indexFileContent = indexFileContent
      .replaceAll("main.dart.js", "main.dart.js?$mainDartJSHashCode")
      .replaceAll("plugins.min.js", "plugins.min.js?$pluginMinJSHashCode");
  File("./build/index.html").writeAsStringSync(indexFileContent);
}

_removeFiles(List<String> files) {
  files.forEach((element) {
    try {
      File(element).deleteSync();
    } catch (e) {}
  });
}

void _copyPathSync(String from, String to) {
  Directory(to).createSync(recursive: true);
  for (final file in Directory(from).listSync(recursive: true)) {
    final copyTo = p.join(to, p.relative(file.path, from: from));
    if (file is Directory) {
      Directory(copyTo).createSync(recursive: true);
    } else if (file is File) {
      File(file.path).copySync(copyTo);
    } else if (file is Link) {
      Link(copyTo).createSync(file.targetSync(), recursive: true);
    }
  }
}
