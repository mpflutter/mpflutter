import 'dart:convert';
import 'dart:io';

import 'package:mp_build_tools/i18n.dart';
import 'package:path/path.dart' as p;
import 'package:crypto/crypto.dart';
import 'package:http/http.dart';

import 'build_plugins.dart' as plugin_builder;

main(List<String> args) async {
  print(I18n.building());
  _checkPubspec();
  _createBuildDir();
  await _buildDartJS(args);
  await plugin_builder.main(args);
  await _copyWebSource();
  await _copyDistSource();
  print(I18n.buildSuccess('build'));
}

_checkPubspec() {
  if (!File('pubspec.yaml').existsSync()) {
    throw I18n.pubspecYamlNotExists();
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

Future _buildDartJS(List<String> args) async {
  final dart2JSParams = args.toList();
  if (!dart2JSParams.any((element) => element.startsWith('-O'))) {
    dart2JSParams.add('-O4');
  }
  final dart2JsResult = Process.runSync(
      'dart',
      [
        'compile',
        'js',
        p.join('lib', 'main.dart'),
        ...dart2JSParams,
        '-Ddart.vm.product=true',
        '-Dmpflutter.hostType=browser',
        '-o',
        p.join('build', 'main.dart.js')
      ]..removeWhere((element) => element.isEmpty),
      runInShell: true);
  if (dart2JsResult.exitCode != 0) {
    print(dart2JsResult.stdout);
    print(dart2JsResult.stderr);
    throw I18n.executeFail('dart2js');
  }
  _fixDefererLoader();
  await _addHashToDeferredParts();
  final buildBundleResult = Process.runSync(
    'flutter',
    [
      'build',
      'bundle',
    ],
    runInShell: true,
    environment: {'PUB_HOSTED_URL': 'https://pub.mpflutter.com'},
  );
  if (buildBundleResult.exitCode != 0) {
    print(buildBundleResult.stdout);
    print(buildBundleResult.stderr);
    throw I18n.executeFail('flutter build bundle');
  }
  if (Directory(p.join('build', 'flutter_assets')).existsSync()) {
    Directory(p.join('build', 'flutter_assets'))
        .renameSync(p.join('build', 'assets'));
  }
  _removeFiles([
    p.join('build', 'assets', 'isolate_snapshot_data'),
    p.join('build', 'assets', 'kernel_blob.bin'),
    p.join('build', 'assets', 'vm_snapshot_data'),
    p.join('build', 'assets', 'snapshot_blob.bin.d'),
  ]);
}

_fixDefererLoader() {
  var code = File(p.join('build', 'main.dart.js')).readAsStringSync();
  code = code.replaceAllMapped(RegExp(r"m=\$\.([a-z0-9A-Z]+)\(\)\nm.toString"),
      (match) {
    return "m=\$.${match.group(1)}() || ''\nm.toString";
  });
  code = code.replaceFirst(
      "\$.\$get\$thisScript();", "\$.\$get\$thisScript() || '';");
  code = code.replaceFirst("k=self.encodeURIComponent(a)", "k=a");
  code = code.replaceFirst("v.currentScript=a",
      "v.currentScript=document.createElement('script');v.currentScript.src='./main.dart.js';");
  File(p.join('build', 'main.dart.js')).writeAsStringSync(code);
}

_addHashToDeferredParts() async {
  var code = File(p.join('build', 'main.dart.js')).readAsStringSync();
  var allFileHash = <String, String>{};
  await Future.wait(Directory('build').listSync().map((e) async {
    final ee = e.path.split(p.separator).last;
    final hashCode = File(p.join('build', ee)).existsSync()
        ? (await md5.bind(File(p.join('build', ee)).openRead()).first)
            .toString()
            .substring(0, 8)
        : "";
    allFileHash[ee] = hashCode;
  }));
  code = code.replaceAllMapped(RegExp(r"deferredPartUris:(.*?),\n"), (match) {
    final data = match.group(1);
    if (data != null) {
      final parts = json.decode(data) as List;
      final newParts = <String>[];
      parts.forEach((element) {
        if (element is String) {
          newParts.add('$element?${allFileHash[element]}');
        }
      });
      return "deferredPartUris:${json.encode(newParts)},\n";
    } else {
      return "deferredPartUris:[],\n";
    }
  });
  File(p.join('build', 'main.dart.js')).writeAsStringSync(code);
}

_copyWebSource() async {
  _copyPathSync(p.join('web'), p.join('build'));
  final mainDartJSHashCode = File(p.join('build', 'main.dart.js')).existsSync()
      ? (await md5.bind(File(p.join('build', 'main.dart.js')).openRead()).first)
          .toString()
          .substring(0, 8)
      : "";
  final pluginMinJSHashCode =
      File(p.join('build', 'plugins.min.js')).existsSync()
          ? (await md5
                  .bind(File(p.join('build', 'plugins.min.js')).openRead())
                  .first)
              .toString()
              .substring(0, 8)
          : "";
  var indexFileContent = File(p.join('web', 'index.html')).readAsStringSync();
  indexFileContent =
      indexFileContent.replaceAll("var dev = true;", "var dev = false;");
  indexFileContent = indexFileContent
      .replaceAll("main.dart.js", "main.dart.js?$mainDartJSHashCode")
      .replaceAll("plugins.min.js", "plugins.min.js?$pluginMinJSHashCode");
  File(p.join('build', 'index.html')).writeAsStringSync(indexFileContent);
}

_copyDistSource() async {
  var indexFileContent = File(p.join('build', 'index.html')).readAsStringSync();
  final matches =
      RegExp("\"(https://dist\.mpflutter\.com/dist/.*?/dist_web/)(.*?)\"")
          .allMatches(indexFileContent);
  for (var element in matches) {
    final prefix = element.group(1) as String;
    final filename = element.group(2) as String;
    final url = "$prefix$filename";
    final urlRes = await get(Uri.parse(url));
    File(p.join('build', filename)).writeAsStringSync(urlRes.body);
  }
  indexFileContent = indexFileContent.replaceAllMapped(
      RegExp("\"https://dist\.mpflutter\.com/dist/(.*?)/dist_web/(.*?)\""),
      (match) {
    return '"${match.group(2)}?${match.group(1)}"';
  });
  File(p.join('build', 'index.html')).writeAsStringSync(indexFileContent);
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
