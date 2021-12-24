import 'dart:convert';
import 'dart:io';

import 'i18n.dart';

main(List<String> args) {
  if (!File('.packages').existsSync()) return;
  final stringBuffers = <String, StringBuffer>{
    'weapp': StringBuffer(),
    'swanapp': StringBuffer(),
    'web': StringBuffer(),
  };
  final lines = File('./.packages').readAsLinesSync();
  for (final line in lines) {
    final pkgPath = line
        .replaceFirst(RegExp('.*?:'), '')
        .replaceFirst('file://', '')
        .replaceFirst('/lib/', '');
    if (File('$pkgPath/package.json').existsSync()) {
      runNpmBuild(pkgPath);
      if (File('$pkgPath/dist/weapp/bundle.min.js').existsSync()) {
        stringBuffers['weapp']!.writeln(
            File('$pkgPath/dist/weapp/bundle.min.js').readAsStringSync());
      }
      if (File('$pkgPath/dist/web/bundle.min.js').existsSync()) {
        stringBuffers['web']!.writeln(
            File('$pkgPath/dist/web/bundle.min.js').readAsStringSync());
      }
      if (File('$pkgPath/dist/swanapp/bundle.min.js').existsSync()) {
        stringBuffers['swanapp']!.writeln(
            File('$pkgPath/dist/swanapp/bundle.min.js').readAsStringSync());
      }
    }
  }
  try {
    File('web/plugins.min.js').writeAsStringSync(
        '''var MPEnv = window.MPDOM.MPEnv;var MPMethodChannel = window.MPDOM.MPMethodChannel;var MPEventChannel = window.MPDOM.MPEventChannel;var MPPlatformView = window.MPDOM.MPPlatformView;var MPComponentFactory = window.MPDOM.ComponentFactory;var pluginRegisterer = window.MPDOM.PluginRegister;''' +
            stringBuffers['web']!.toString() +
            htmlTemplateCode());
  } catch (e) {}
  try {
    File('weapp/plugins.min.js').writeAsStringSync(
        '''var MPEnv = require("./mpdom.min").MPEnv;var MPMethodChannel = require("./mpdom.min").MPMethodChannel;var MPEventChannel = require("./mpdom.min").MPEventChannel;var MPPlatformView = require("./mpdom.min").MPPlatformView;var MPComponentFactory = require("./mpdom.min").ComponentFactory;var pluginRegisterer = require("./mpdom.min").PluginRegister;''' +
            stringBuffers['weapp']!.toString());
    File('weapp/plugins.wxml').writeAsStringSync(weappTemplateCode());
  } catch (e) {}
  try {
    File('swanapp/plugins.min.js').writeAsStringSync(
        '''var MPEnv = require("./mpdom.min").MPEnv;var MPMethodChannel = require("./mpdom.min").MPMethodChannel;var MPEventChannel = require("./mpdom.min").MPEventChannel;var MPPlatformView = require("./mpdom.min").MPPlatformView;var MPComponentFactory = require("./mpdom.min").ComponentFactory;var pluginRegisterer = require("./mpdom.min").PluginRegister;''' +
            stringBuffers['swanapp']!.toString());
    File('swanapp/plugins.swan').writeAsStringSync(swanappTemplateCode());
  } catch (e) {}
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

String htmlTemplateCode() {
  var code = '';
  final stringBuffer = StringBuffer();
  final lines = File('./.packages').readAsLinesSync();
  for (final line in lines) {
    final pkgPath = line
        .replaceFirst(RegExp('.*?:'), '')
        .replaceFirst('file://', '')
        .replaceFirst('/lib/', '');
    if (File('$pkgPath/dist/index.min.js').existsSync()) {
      final files = fetchFilesWithSubfix(Directory(pkgPath + '/lib'), '.html');
      files.forEach((file) {
        stringBuffer.write(File(file).readAsStringSync());
      });
    }
  }
  if (stringBuffer.isNotEmpty) {
    code = '''(function() {
  var child = document.createElement('div');
  child.innerHTML = atob('${base64.encode(utf8.encode(stringBuffer.toString()))}');
  document.body.appendChild(child);
})();''';
  }
  return code;
}

String weappTemplateCode() {
  var code = '';
  final stringBuffer = StringBuffer();
  final lines = File('./.packages').readAsLinesSync();
  for (final line in lines) {
    final pkgPath = line
        .replaceFirst(RegExp('.*?:'), '')
        .replaceFirst('file://', '')
        .replaceFirst('/lib/', '');
    if (File('$pkgPath/dist/index.min.js').existsSync()) {
      final files = fetchFilesWithSubfix(Directory(pkgPath + '/lib'), '.wxml');
      files.forEach((file) {
        stringBuffer.write(File(file).readAsStringSync());
      });
    }
  }
  if (stringBuffer.isNotEmpty) {
    code = stringBuffer.toString();
  }
  return code;
}

String swanappTemplateCode() {
  var code = '';
  final stringBuffer = StringBuffer();
  final lines = File('./.packages').readAsLinesSync();
  for (final line in lines) {
    final pkgPath = line
        .replaceFirst(RegExp('.*?:'), '')
        .replaceFirst('file://', '')
        .replaceFirst('/lib/', '');
    if (File('$pkgPath/dist/index.min.js').existsSync()) {
      final files = fetchFilesWithSubfix(Directory(pkgPath + '/lib'), '.swan');
      files.forEach((file) {
        stringBuffer.write(File(file).readAsStringSync());
      });
    }
  }
  if (stringBuffer.isNotEmpty) {
    code = stringBuffer.toString();
  }
  return code;
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
