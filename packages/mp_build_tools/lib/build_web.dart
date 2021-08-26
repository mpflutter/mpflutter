import 'dart:io';

import 'build_plugins.dart' as plugin_builder;

main(List<String> args) {
  _checkPubspec();
  _createBuildDir();
  final hashCode = _buildDartJS();
  plugin_builder.main(args);
  _copyWebSource(hashCode);
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

String _buildDartJS() {
  Process.runSync(
      'dart2js',
      [
        'lib/main.dart',
        '-O4',
        '-Ddart.vm.product=true',
        '-o',
        'build/main.dart.js'
      ],
      runInShell: true);
  _fixDefererLoader();
  Process.runSync(
    'flutter',
    [
      'build',
      'bundle',
    ],
    runInShell: true,
  );
  if (Directory('./build/flutter_assets').existsSync()) {
    Directory('./build/flutter_assets').renameSync('./build/assets');
  }
  _removeFiles([
    './build/assets/isolate_snapshot_data',
    './build/assets/kernel_blob.bin',
    './build/assets/vm_snapshot_data',
    './build/snapshot_blob.bin.d'
  ]);
  return File('./build/assets/.last_build_id')
      .readAsStringSync()
      .substring(0, 6);
}

_fixDefererLoader() {
  var code = File('build/main.dart.js').readAsStringSync();
  code = code.replaceFirstMapped(
      RegExp(r"m=\$\.([a-z0-9A-Z].?)\(\)\nm.toString"), (match) {
    return "m=\$.${match.group(1)}() || ''\nm.toString";
  });
  code = code.replaceFirst(
      "\$.\$get\$thisScript();", "\$.\$get\$thisScript() || '';");
  File('build/main.dart.js').writeAsStringSync(code);
}

_copyWebSource(String hashCode) {
  var indexFileContent = File('./web/index.html').readAsStringSync();
  indexFileContent =
      indexFileContent.replaceAll("var dev = true;", "var dev = false;");
  indexFileContent = indexFileContent
      .replaceAll("'main.dart.js'", "'main.dart.js?$hashCode'")
      .replaceAll("'plugins.min.js'", "'plugins.min.js?$hashCode'");
  File("./build/index.html").writeAsStringSync(indexFileContent);
  if (File("./web/index.css").existsSync()) {
    File("./web/index.css").copySync("./build/index.css");
  }
  if (File("./web/plugins.min.js").existsSync()) {
    File("./web/plugins.min.js").copySync("./build/plugins.min.js");
  }
}

_removeFiles(List<String> files) {
  files.forEach((element) {
    try {
      File(element).deleteSync();
    } catch (e) {}
  });
}
