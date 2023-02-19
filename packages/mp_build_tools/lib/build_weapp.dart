import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'build_plugins.dart' as plugin_builder;
import 'i18n.dart';

final Map<int, List<String>> subpackages = {};
final subpackageSizeLimited = 1024 * 1024 * 1.9;
Map? miniProgramConfig;
List<String> miniProgramPages = [];
Map? appJson;

main(List<String> args) {
  print(I18n.building());
  appJson = json.decode(
    File(p.join('weapp', 'app.json')).readAsStringSync(),
  ) as Map;
  _checkPubspec();
  _createBuildDir();
  miniProgramConfig = _fetchMiniProgramConfig();
  plugin_builder.main(args);
  _copyWeappSource();
  _createPages();
  _buildDartJS(args);
  _treeSharkInnerComponent();
  File(p.join('build', 'app.json')).writeAsStringSync(json.encode(appJson));
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

Map? _fetchMiniProgramConfig() {
  if (File(p.join('lib', 'weapp.config.dart')).existsSync()) {
    try {
      final result =
          Process.runSync('dart', [p.join('lib', 'weapp.config.dart')]);
      return json.decode(result.stdout);
    } catch (e) {}
  }
  return null;
}

void _buildDartJS(List<String> args) {
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
        '-Dmpflutter.hostType=wechatMiniProgram',
        '--csp',
        '-o',
        p.join('build', 'main.dart.js'),
      ]..removeWhere((element) => element.isEmpty),
      runInShell: true);
  if (dart2JsResult.exitCode != 0) {
    print(dart2JsResult.stdout);
    print(dart2JsResult.stderr);
    throw I18n.executeFail('dart2js');
  }
  _fixDefererLoader();
  _fixCryptoRequire();
  _moveDeferedScriptToSubpackages();
  _writeSubpackagesToAppJson();
  _writeSubpackageLoader();
  var codeSource = File(p.join('build', 'main.dart.js')).readAsStringSync();
  codeSource = codeSource
      .replaceAll(RegExp(r"\n}\)\(\);"), "\n});")
      .replaceAll("else s([])})})()", "else s([])})})");
  codeSource =
      "let MPEnv = require('./mpdom.min').MPEnv;self = MPEnv.platformGlobal();" +
          codeSource;
  codeSource = codeSource.replaceFirst("""(function dartProgram()""",
      """var \$__dart_deferred_initializers__ = self.\$__dart_deferred_initializers__;module.exports.main = (function dartProgram()""");
  File(p.join('build', 'main.dart.js')).writeAsStringSync(codeSource);
  var appSource = File(p.join('build', 'app.js')).readAsStringSync();
  appSource = appSource.replaceAll(
      RegExp(r"""var\sdev\s=\strue;?"""), "var dev = false;");
  File(p.join('build', 'app.js')).writeAsStringSync(appSource);
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

_copyWeappSource() {
  _copyPathSync(p.join('weapp'), p.join('build'));
  File(p.join('build', 'app.json')).deleteSync();
}

_createPages() {
  if (miniProgramConfig == null) return;
  if (miniProgramConfig!['pages'] is Map) {
    (miniProgramConfig!['pages'] as Map).forEach((path, pageConfig) {
      if (path is String && path == '/' && pageConfig is Map) {
        final jsonPath = p.joinAll(['build', 'pages', 'index', 'index.json']);
        File(jsonPath).writeAsStringSync(json.encode(
          {}..addAll({
              'usingComponents': {
                'element': '../../kbone/miniprogram-element/index'
              }
            }..addAll(pageConfig)),
        ));
      } else if (path is String && path.startsWith('/') && pageConfig is Map) {
        miniProgramPages.add(path.substring(1));
        final jsPath =
            p.joinAll(['build', ...path.split("/")..removeAt(0)]) + '.js';
        final wxmlPath =
            p.joinAll(['build', ...path.split("/")..removeAt(0)]) + '.wxml';
        final jsonPath =
            p.joinAll(['build', ...path.split("/")..removeAt(0)]) + '.json';
        String coreLibRequireBase = '';
        (path.split("/")
              ..removeAt(0)
              ..removeLast())
            .forEach((element) {
          coreLibRequireBase += '../';
        });
        if (coreLibRequireBase.isEmpty) {
          coreLibRequireBase = './';
        }
        File(jsPath).writeAsStringSync('''
const WXPage = require('${coreLibRequireBase}mpdom.min').WXPage;

const thePage = new WXPage({route: '${path}'});
thePage.kboneRender = require('${coreLibRequireBase}kbone/miniprogram-render/index')
Page(thePage);
        ''');
        File(jsonPath).writeAsStringSync(json.encode(
          {}..addAll({
              'usingComponents': {
                'element':
                    '${coreLibRequireBase}kbone/miniprogram-element/index',
                'loading-view': '${coreLibRequireBase}pages/loading-view/index'
              }
            }..addAll(pageConfig)),
        ));
        File(wxmlPath).writeAsStringSync('''
<page-meta><navigation-bar title="{{pageMeta.naviBar.title}}" loading="{{pageMeta.naviBar.loading}}" front-color="{{pageMeta.naviBar.frontColor || '#000000'}}" background-color="{{pageMeta.naviBar.backgroundColor || '#ffffff'}}"></navigation-bar></page-meta>
<element wx:if="{{pageId}}" class="miniprogram-root" data-private-node-id="e-body" data-private-page-id="{{pageId}}" ></element>
<view wx:if="{{!didReceivedFirstFrame}}" style="position: fixed; background-color: transparent; width: 100vw; height: 100vh">
    <loading-view />
</view>
<canvas type="2d" id="mockOffscreenCanvas" style="display:none"></canvas>
        ''');
      }
    });
  }
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
    final fileName = p.basename(element.path);
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
    File(currentSubpackageLocation().path + '/loader.wxml')
        .writeAsStringSync('<view></view>');
    File(currentSubpackageLocation().path + '/loader.js').writeAsStringSync('''
    Page({
        onLoad: function() {
            ${currentSubpackageFiles.map((e) => '''require('./${e.replaceAll('.part.js', '.part')}').main();''').join('\n')}
            wx.showLoading({
              title: '加载中',
            });
            setTimeout(() => {
                wx.hideLoading();
                wx.navigateBack({success: function() {
                    global.dartDeferedLoadedFlag = true;
                }});
            }, 1000);
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
  if (appJson == null) return;
  (appJson!['pages'] as List)..addAll(miniProgramPages);
  if (subpackages.isNotEmpty) {
    appJson!['subpackages'] ??= [];
    (appJson!['subpackages'] as List)
      ..addAll(subpackages.keys.map((e) {
        return {
          "root": "dart_package_$e",
          "pages": ["loader"]
        };
      }).toList());
  }
}

_writeSubpackageLoader() {
  if (subpackages.isNotEmpty) {
    final fileMapping = {};
    subpackages.forEach((pkgIndex, value) {
      value.forEach((fileName) {
        fileMapping[fileName] = pkgIndex;
        fileMapping['/' + fileName] = pkgIndex;
      });
    });
    final loaderCode = """
var subpackageFileMapping = JSON.parse('${json.encode(fileMapping)}');
self.dartDeferredLibraryLoader = function(uri, res, rej) {
  if (subpackageFileMapping[uri] !== undefined) {
    if (typeof require === "function" && typeof require.async === "function") {
      require("dart_package_" + subpackageFileMapping[uri] + "/" + uri, function (result) {
        if (result.main) {
          result.main();
          res();
        } else {
          rej();
        }
      });
    } else {
      global.dartDeferedLoadedFlag = false;
      setTimeout(() => {
        wx.navigateTo({
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
  }
  else {
    rej('File not found.');
  }
};
""";
    var code = File(p.join('build', 'main.dart.js')).readAsStringSync();
    code = code + loaderCode;
    File(p.join('build', 'main.dart.js')).writeAsStringSync(code);
  }
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
      "v.currentScript={src:'/',getAttribute:function(){return '';}};");
  File(p.join('build', 'main.dart.js')).writeAsStringSync(code);
}

_fixCryptoRequire() {
  var code = File(p.join('build', 'main.dart.js')).readAsStringSync();
  if (code.contains('self.require("crypto")')) {
    code = code.replaceAll('self.require("crypto")', 'require("./crypto")');
    File(p.join('build', 'main.dart.js')).writeAsStringSync(code);
    File(p.join('build', 'crypto.js')).writeAsStringSync('''
let lastRandomValues = undefined;

export const genRandomValues = () => {
  if (wx && wx.getRandomValues) {
    wx.getRandomValues({
      length: 32,
      success: (res) => {
        lastRandomValues = new Uint8Array(res.randomValues);
      }
    })
  }
  else {
    console.warn("不存在 wx.getRandomValues 接口，正在使用伪随机数。");
    let arr = [];
    for (let index = 0; index < 32; index++) {
      arr.push(Math.floor(Math.random() * 255));
    }
    lastRandomValues = new Uint8Array(arr);
  }
}

export const randomFillSync = (buffer) => {
  genRandomValues();
  if (lastRandomValues) {
    for (let index = 0; index < lastRandomValues.length; index++) {
      buffer[index] = lastRandomValues[index];
    }
  }
}
''');
    var appJSCode = File(p.join('build', 'app.js')).readAsStringSync();
    appJSCode = "require('./crypto').genRandomValues();\n" + appJSCode;
    File(p.join('build', 'app.js')).writeAsStringSync(appJSCode);
  }
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

void _treeSharkInnerComponent() {
  try {
    final codes = <String>[];
    codes.add(File(p.join('build', 'main.dart.js')).readAsStringSync());
    codes.add(File(p.join('build', 'mpdom.min.js')).readAsStringSync());
    subpackages.keys.forEach((e) {
      Directory("build/dart_package_$e").listSync().forEach((file) {
        if (file.path.endsWith('.part.js')) {
          codes.add(File(file.absolute.path).readAsStringSync());
        }
      });
    });
    final innerComponentXml =
        File("build/kbone/miniprogram-element/template/inner-component.wxml")
            .readAsStringSync();
    var newXmlContents = '';
    RegExp('<template name="(.*?)">(.*?)</template>', caseSensitive: false)
        .allMatches(innerComponentXml)
        .forEach((element) {
      final name = element.group(1);
      final content = element.group(2);
      for (var i = 0; i < codes.length; i++) {
        if (codes[i].contains('wx-${name}') || codes[i].contains('"${name}"')) {
          newXmlContents += '<template name="${name}">${content}</template>';
          break;
        }
      }
    });
    File("build/kbone/miniprogram-element/template/inner-component.wxml")
        .writeAsStringSync(newXmlContents);
  } catch (e) {}
}
