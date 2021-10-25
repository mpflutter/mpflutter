import 'dart:convert';
import 'dart:io';

main(List<String> args) {
  if (!File('.packages').existsSync()) return;
  final stringBuffer = StringBuffer();
  final lines = File('./.packages').readAsLinesSync();
  for (final line in lines) {
    final pkgPath = line
        .replaceFirst(RegExp('.*?:'), '')
        .replaceFirst('file://', '')
        .replaceFirst('/lib/', '');
    if (File('$pkgPath/dist/index.min.js').existsSync()) {
      stringBuffer
          .writeln(File('$pkgPath/dist/index.min.js').readAsStringSync());
    }
  }
  try {
    File('web/plugins.min.js').writeAsStringSync(
        '''var MPEnv = window.MPDOM.MPEnv;var MPPlatformView = window.MPDOM.MPPlatformView;var MPComponentFactory = window.MPDOM.ComponentFactory;var pluginRegisterer = {env: MPEnv,registerPlugin: function(name, target) {MPEnv.platformGlobal()[name] = target;},registerPlatformView: function(name, target){MPComponentFactory.components[name] = target;}};''' +
            stringBuffer.toString() +
            htmlTemplateCode());
  } catch (e) {}
  try {
    File('weapp/plugins.min.js').writeAsStringSync(
        '''var MPEnv = require("./mpdom.min").MPEnv;var MPPlatformView = require("./mpdom.min").MPPlatformView;var MPComponentFactory = require("./mpdom.min").ComponentFactory;var pluginRegisterer = {env: MPEnv,registerPlugin: function(name, target) {MPEnv.platformGlobal()[name] = target;},registerPlatformView: function(name, target){MPComponentFactory.components[name] = target;}};''' +
            stringBuffer.toString());
    File('weapp/plugins.wxml').writeAsStringSync(weappTemplateCode());
  } catch (e) {}
  try {
    File('swanapp/plugins.min.js').writeAsStringSync(
        '''var MPEnv = require("./mpdom.min").MPEnv;var MPPlatformView = require("./mpdom.min").MPPlatformView;var MPComponentFactory = require("./mpdom.min").ComponentFactory;var pluginRegisterer = {env: MPEnv,registerPlugin: function(name, target) {MPEnv.platformGlobal()[name] = target;},registerPlatformView: function(name, target){MPComponentFactory.components[name] = target;}};''' +
            stringBuffer.toString());
    File('swanapp/plugins.swan').writeAsStringSync(swanappTemplateCode());
  } catch (e) {}
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
