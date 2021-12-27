import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'build_plugins.dart' as plugin_builder;
import 'i18n.dart';

final Map<int, List<String>> subpackages = {};
final subpackageSizeLimited = 1024 * 1024 * 1.9;

main(List<String> args) {
  print(I18n.building());
  _checkPubspec();
  _createBuildDir();
  plugin_builder.main(args);
  _copySwanappSource();
  _buildDartJS(args);
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

String _buildDartJS(List<String> args) {
  final dart2JSParams = args.toList();
  if (!dart2JSParams.any((element) => element.startsWith('-O'))) {
    dart2JSParams.add('-O4');
  }
  final dart2JsResult = Process.runSync(
      'dart2js',
      [
        'lib/main.dart',
        ...dart2JSParams,
        '-Ddart.vm.product=true',
        '-Dmpflutter.hostType=wechatMiniProgram',
        '--csp',
        '-o',
        'build/main.dart.js'
      ]..removeWhere((element) => element.isEmpty),
      runInShell: true);
  if (dart2JsResult.exitCode != 0) {
    print(dart2JsResult.stdout);
    print(dart2JsResult.stderr);
    throw I18n.executeFail('dart2js');
  }
  _fixDefererLoader();
  _moveDeferedScriptToSubpackages();
  _writeSubpackagesToAppJson();
  _writeSubpackageLoader();
  var codeSource = File('./build/main.dart.js').readAsStringSync();
  codeSource = codeSource
      .replaceAll(RegExp(r"\n}\)\(\);"), "\n});")
      .replaceAll("else s([])})})()", "else s([])})})");
  codeSource =
      "let MPEnv = require('./mpdom.min').MPEnv;self = MPEnv.platformGlobal();" +
          codeSource;
  codeSource = codeSource.replaceFirst("""(function dartProgram()""",
      """var \$__dart_deferred_initializers__ = self.\$__dart_deferred_initializers__;module.exports.main = (function dartProgram()""");
  File('./build/main.dart.js').writeAsStringSync(codeSource);
  var appSource = File('./build/app.js').readAsStringSync();
  appSource = appSource.replaceAll("var dev = true;", "var dev = false;");
  File('./build/app.js').writeAsStringSync(appSource);
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

_copySwanappSource() {
  _copyPathSync('./swanapp', './build/');
}

_moveDeferedScriptToSubpackages() {
  var currentSubpackageIndex = 0;
  var currentSubpackageSize = 0.0;
  var currentSubpackageLocation =
      () => Directory(p.join('build', 'dart_package_$currentSubpackageIndex'));
  var currentSubpackageFiles = <String>[];
  Directory('build')
      .listSync()
      .where((element) => element.path.endsWith('.part.js'))
      .forEach((element) {
    if (!subpackages.containsKey(currentSubpackageIndex)) {
      subpackages[currentSubpackageIndex] = [];
    }
    if (!currentSubpackageLocation().existsSync()) {
      currentSubpackageFiles = [];
      currentSubpackageLocation().createSync();
    }
    final fileName = element.path.split("/").removeLast();
    subpackages[currentSubpackageIndex]!.add(fileName);
    currentSubpackageFiles.add(fileName);
    currentSubpackageSize += File(element.path).statSync().size;
    File(element.path).copySync(
      p.join(currentSubpackageLocation().path, fileName),
    );
    File(element.path).deleteSync();
    _modulizeDeferedJSCode(
        File(p.join(currentSubpackageLocation().path, fileName)));
    try {
      File(element.path + ".map").copySync(
        p.join(currentSubpackageLocation().path, fileName + ".map"),
      );
      File(element.path + ".map").deleteSync();
    } catch (e) {}
    File(currentSubpackageLocation().path + '/loader.json')
        .writeAsStringSync('{}');
    File(currentSubpackageLocation().path + '/loader.swan')
        .writeAsStringSync('');
    File(currentSubpackageLocation().path + '/loader.js').writeAsStringSync('''
    Page({
        onLoad: function() {
            ${currentSubpackageFiles.map((e) => '''require('./${e.replaceAll('.part.js', '.part')}').main();''').join('\n')}
            swan.navigateBack({success: function() {
                global.dartDeferedLoadedFlag = true;
            }});
        },
    })
    ''');
    if (currentSubpackageSize >= subpackageSizeLimited) {
      currentSubpackageIndex++;
      currentSubpackageSize = 0;
    }
  });
}

_modulizeDeferedJSCode(File file) {
  var code = file.readAsStringSync();
  code =
      "self = getApp();var \$__dart_deferred_initializers__ = self.\$__dart_deferred_initializers__;module.exports.main = function() {$code};";
  file.writeAsStringSync(code);
}

_writeSubpackagesToAppJson() {
  if (subpackages.isNotEmpty) {
    var appJson = json.decode(
      File(p.join('build', 'app.json')).readAsStringSync(),
    ) as Map;
    appJson['subPackages'] ??= [];
    (appJson['subPackages'] as List)
      ..addAll(subpackages.keys.map((e) {
        return {
          "root": "dart_package_$e",
          "pages": ["loader"]
        };
      }).toList());
    File(p.join('build', 'app.json')).writeAsStringSync(json.encode(appJson));
  }
}

_writeSubpackageLoader() {
  if (subpackages.isNotEmpty) {
    final fileMapping = {};
    subpackages.forEach((pkgIndex, value) {
      value.forEach((fileName) {
        fileMapping[fileName] = pkgIndex;
      });
    });
    final loaderCode = """
var subpackageFileMapping = JSON.parse('${json.encode(fileMapping)}');
self.dartDeferredLibraryLoader = function(uri, res, rej) {
  if (subpackageFileMapping[uri] !== undefined) {
    global.dartDeferedLoadedFlag = false;
    setTimeout(() => {
      swan.navigateTo({
        url: "/dart_package_" + subpackageFileMapping[uri] + "/loader",
        success: function () {
            var intervalHandler;
            intervalHandler = setInterval(function () {
                if (global.dartDeferedLoadedFlag) {
                  clearInterval(intervalHandler);
                  res();
                }
            }, 100);
        },
      });
    }, 300);
  }
  else {
    rej('File not found.');
  }
};
""";
    var code = File('build/main.dart.js').readAsStringSync();
    code = code + loaderCode;
    File('build/main.dart.js').writeAsStringSync(code);
  }
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
