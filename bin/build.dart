part of 'mpflutter.dart';

void build(List<String> args) {
  final target = args.length <= 1 || args[1] == 'web' ? 'web' : args[1];
  final isDebug = args.length > 2 && args[2] == '--debug';
  if (target == 'web') {
    _buildWeb();
  } else if (target == 'weapp') {
    if (isDebug) {
      _buildTaroDebug("weapp");
    } else {
      _buildTaro("weapp");
    }
  }
}

void _clearWorkspace() {
  try {
    Directory(path.join('build')).deleteSync(recursive: true);
  } catch (e) {}
  Directory(path.join('build')).createSync();
}

void _buildPlugin() {
  if (File('lib/generated_plugin_registrant.dart').existsSync()) {
    final code = File('lib/generated_plugin_registrant.dart')
        .readAsStringSync()
        .replaceFirst("import 'dart:ui';", '');
    File('lib/generated_plugin_registrant.dart').writeAsStringSync(code);
  }
}
