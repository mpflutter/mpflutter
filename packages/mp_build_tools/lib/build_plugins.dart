import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;

import 'i18n.dart';

main(List<String> args) {
  if (!File('.packages').existsSync() &&
      !File('.dart_tool/package_config.json').existsSync()) return;
  if (File('.packages').existsSync()) {
    final lines = File('.packages').readAsLinesSync();
    for (final line in lines) {
      try {
        final pkgPath = line
            .replaceFirst(RegExp('.*?:'), '')
            .replaceFirst('file://', '')
            .replaceFirst('/lib/', '');
        if (File(path.join(pkgPath, 'package.json')).existsSync() &&
            (Directory(path.join(pkgPath, 'lib', 'web')).existsSync() ||
                Directory(path.join(pkgPath, 'lib', 'weapp')).existsSync())) {
          runNpmBuild(pkgPath);
        }
      } catch (e) {}
    }
  } else if (File('.dart_tool/package_config.json').existsSync()) {
    final pkgs = json.decode(
        File('.dart_tool/package_config.json').readAsStringSync())['packages'];
    for (final pkg in pkgs) {
      try {
        final pkgPath = pkg["rootUri"]
            .replaceFirst('../', './')
            .replaceFirst('file://', '')
            .replaceFirst('/lib/', '');
        if (File(path.join(pkgPath, 'package.json')).existsSync() &&
            (Directory(path.join(pkgPath, 'lib', 'web')).existsSync() ||
                Directory(path.join(pkgPath, 'lib', 'weapp')).existsSync())) {
          runNpmBuild(pkgPath);
        }
      } catch (e) {}
    }
  }
  buildWebPlugin();
  buildMPPlugin('weapp');
}

void buildWebPlugin() {
  if (!Directory('web').existsSync()) return;
  final stringBuffer = StringBuffer();
  if (File('.packages').existsSync()) {
    final lines = File('.packages').readAsLinesSync();
    for (final line in lines) {
      try {
        final pkgPath = line
            .replaceFirst(RegExp('.*?:'), '')
            .replaceFirst('file://', '')
            .replaceFirst('/lib/', '');
        if (File(path.join(pkgPath, 'dist', 'web', 'bundle.min.js'))
            .existsSync()) {
          stringBuffer.writeln(
              File(path.join(pkgPath, 'dist', 'web', 'bundle.min.js'))
                  .readAsStringSync());
        }
      } catch (e) {}
    }
    try {
      File('web/plugins.min.js').writeAsStringSync(
          '''var MPEnv = window.MPDOM.MPEnv;var MPMethodChannel = window.MPDOM.MPMethodChannel;var MPEventChannel = window.MPDOM.MPEventChannel;var MPPlatformView = window.MPDOM.MPPlatformView;var MPComponentFactory = window.MPDOM.ComponentFactory;var pluginRegisterer = window.MPDOM.PluginRegister;''' +
              stringBuffer.toString());
    } catch (e) {}
  } else if (File('.dart_tool/package_config.json').existsSync()) {
    final pkgs = json.decode(
        File('.dart_tool/package_config.json').readAsStringSync())['packages'];
    for (final pkg in pkgs) {
      try {
        final pkgPath = pkg["rootUri"]
            .replaceFirst('../', './')
            .replaceFirst('file://', '')
            .replaceFirst('/lib/', '');
        if (File(path.join(pkgPath, 'dist', 'web', 'bundle.min.js'))
            .existsSync()) {
          stringBuffer.writeln(
              File(path.join(pkgPath, 'dist', 'web', 'bundle.min.js'))
                  .readAsStringSync());
        }
      } catch (e) {}
    }
    if (File(path.join('lib', 'mpjs.config.dart')).existsSync()) {
      try {
        final result = Process.runSync('dart', [
          'run',
          '--define=isWeb=true',
          path.join('lib', 'mpjs.config.dart')
        ]);
        final templateScripts = json.decode(result.stdout) as Map;
        templateScripts.forEach((key, value) {
          stringBuffer.writeln('''
try {
  window.\$mpjs_template_${key} = $value;
} catch (e) {
  console.error(e);
}
''');
        });
      } catch (e) {}
    }
    try {
      File('web/plugins.min.js').writeAsStringSync(
          '''var MPEnv = window.MPDOM.MPEnv;var MPMethodChannel = window.MPDOM.MPMethodChannel;var MPEventChannel = window.MPDOM.MPEventChannel;var MPPlatformView = window.MPDOM.MPPlatformView;var MPComponentFactory = window.MPDOM.ComponentFactory;var pluginRegisterer = window.MPDOM.PluginRegister;''' +
              stringBuffer.toString());
    } catch (e) {}
  }
}

void buildMPPlugin(String appType) {
  if (!Directory(appType).existsSync()) return;
  final stringBuffer = StringBuffer();

  final components = <File>[];
  if (File('.packages').existsSync()) {
    final lines = File('./.packages').readAsLinesSync();
    for (final line in lines) {
      try {
        final pkgPath = line
            .replaceFirst(RegExp('.*?:'), '')
            .replaceFirst('file://', '')
            .replaceFirst('/lib/', '');
        if (File(path.join(pkgPath, 'dist', appType, 'bundle.min.js'))
            .existsSync()) {
          stringBuffer.writeln(
              File(path.join(pkgPath, 'dist', appType, 'bundle.min.js'))
                  .readAsStringSync());
        }
        if (Directory(path.join(pkgPath, 'lib', appType, 'components'))
            .existsSync()) {
          // contains wechat components
          Directory(path.join(pkgPath, 'lib', appType, 'components'))
              .listSync()
              .forEach((element) {
            if (element.path.endsWith(".json")) {
              components.add(File(element.path));
            }
          });
        }
      } catch (e) {}
    }
  } else if (File('.dart_tool/package_config.json').existsSync()) {
    final pkgs = json.decode(
        File('.dart_tool/package_config.json').readAsStringSync())['packages'];
    for (final pkg in pkgs) {
      try {
        final pkgPath = pkg["rootUri"]
            .replaceFirst('../', './')
            .replaceFirst('file://', '')
            .replaceFirst('/lib/', '');
        if (File(path.join(pkgPath, 'dist', appType, 'bundle.min.js'))
            .existsSync()) {
          stringBuffer.writeln(
              File(path.join(pkgPath, 'dist', appType, 'bundle.min.js'))
                  .readAsStringSync());
        }
        if (Directory(path.join(pkgPath, 'lib', appType, 'components'))
            .existsSync()) {
          // contains wechat components
          Directory(path.join(pkgPath, 'lib', appType, 'components'))
              .listSync()
              .forEach((element) {
            if (element.path.endsWith(".json")) {
              components.add(File(element.path));
            }
          });
        }
      } catch (e) {}
    }
  }

  if (File(path.join('lib', 'mpjs.config.dart')).existsSync()) {
    try {
      final result = Process.runSync('dart', [
        'run',
        '--define=isMiniProgram=true',
        path.join('lib', 'mpjs.config.dart')
      ]);
      final templateScripts = json.decode(result.stdout) as Map;
      templateScripts.forEach((key, value) {
        stringBuffer.writeln('''
try {
  wx.\$mpjs_template_${key} = $value;
} catch (e) {
  console.error(e);
}
''');
      });
    } catch (e) {}
  }

  try {
    File('${appType}/plugins.min.js').writeAsStringSync(
        '''var MPEnv = require("./mpdom.min").MPEnv;var MPMethodChannel = require("./mpdom.min").MPMethodChannel;var MPEventChannel = require("./mpdom.min").MPEventChannel;var MPPlatformView = require("./mpdom.min").MPPlatformView;var MPComponentFactory = require("./mpdom.min").ComponentFactory;var pluginRegisterer = require("./mpdom.min").PluginRegister;''' +
            stringBuffer.toString());
  } catch (e) {}

  final componentJSON = {
    'component': true,
    'usingComponents': {},
  };
  final componentDefines = {};
  final componentWXML = StringBuffer();
  components.forEach((element) {
    if (!Directory(path.join(appType, 'kbone', 'miniprogram-element',
            'custom-component', 'components'))
        .existsSync()) {
      Directory(path.join(appType, 'kbone', 'miniprogram-element',
              'custom-component', 'components'))
          .createSync();
    }
    String basename = path.basename(element.path).replaceFirst('.json', '');
    String basepath = path.dirname(element.path);
    List props = [];
    List events = [];
    File jsFile = File(path.join(basepath, basename + '.js'));
    File jsonFile = File(path.join(basepath, basename + '.json'));
    File wxmlFile = File(path.join(basepath, basename + '.wxml'));
    File wxssFile = File(path.join(basepath, basename + '.wxss'));
    if (jsFile.existsSync()) {
      jsFile.copySync(path.join(appType, 'kbone', 'miniprogram-element',
          'custom-component', 'components', basename + '.js'));
    }
    if (jsonFile.existsSync()) {
      final jsonData = json.decode(jsonFile.readAsStringSync());
      componentDefines[basename] = jsonData;
      if (jsonData['props'] is List) {
        props.addAll(jsonData['props'] as List);
      }
      if (jsonData['events'] is List) {
        events.addAll(jsonData['events'] as List);
      }
      jsonFile.copySync(path.join(appType, 'kbone', 'miniprogram-element',
          'custom-component', 'components', basename + '.json'));
    }
    if (wxmlFile.existsSync()) {
      wxmlFile.copySync(path.join(appType, 'kbone', 'miniprogram-element',
          'custom-component', 'components', basename + '.wxml'));
    }
    if (wxssFile.existsSync()) {
      wxssFile.copySync(path.join(appType, 'kbone', 'miniprogram-element',
          'custom-component', 'components', basename + '.wxss'));
    }
    (componentJSON['usingComponents'] as Map)[basename] =
        'components/${basename}';
    componentWXML.writeln('''
<${basename} wx:if="{{kboneCustomComponentName === '${basename}'}}" id="{{id}}" class="{{className}}" style="{{style}}" ${props.map((e) {
      return '$e="{{$e}}"';
    }).join(' ')} ${events.map((e) {
      return 'bind$e="on$e"';
    }).join(' ')}>
    <block wx:if="{{hasSlots}}">
        <element wx:for="{{slots}}" wx:key="nodeId" id="{{item.id}}" class="{{item.className}}" style="{{item.style}}" slot="{{item.slot}}" data-private-node-id="{{item.nodeId}}" data-private-page-id="{{item.pageId}}" generic:custom-component="custom-component"></element>
    </block>
    <slot/>
</${basename}>
    ''');
  });
  File(path.join(appType, 'mp-custom-components.js')).writeAsStringSync('''
module.exports = {
  "usingComponents": ${json.encode(componentDefines)}
};
  ''');
  File(path.join(appType, 'kbone', 'miniprogram-element', 'custom-component',
          'index.json'))
      .writeAsStringSync(json.encode(componentJSON));
  File(path.join(appType, 'kbone', 'miniprogram-element', 'custom-component',
          'index.wxml'))
      .writeAsStringSync(componentWXML.toString());
}

void runNpmBuild(String pkgPath) {
  if (!Directory('$pkgPath/node_modules').existsSync()) {
    final npmInstallResult = Process.runSync(
      'npm',
      ['install'],
      workingDirectory: pkgPath,
      runInShell: true,
    );
    if (npmInstallResult.exitCode != 0) {
      print(npmInstallResult.stdout);
      print(npmInstallResult.stderr);
      print(I18n.needNodeEnv());
      throw I18n.executeFail('npm install');
    }
  }
  final npmBuildResult = Process.runSync('npm', ['run', 'build'],
      workingDirectory: pkgPath, runInShell: true);
  if (npmBuildResult.exitCode != 0) {
    print(npmBuildResult.stdout);
    print(npmBuildResult.stderr);
    print(I18n.needNodeEnv());
    throw I18n.executeFail('npm run build');
  }
}

List<String> fetchFilesWithSubfix(Directory dir, String subfix) {
  final result = <String>[];
  dir.listSync().forEach((element) {
    if (element.statSync().type == FileSystemEntityType.directory) {
      result.addAll(fetchFilesWithSubfix(Directory(element.path), subfix));
    } else if (element.path.endsWith(subfix) &&
        element.statSync().type == FileSystemEntityType.file) {
      result.add(element.path);
    }
  });
  return result;
}
