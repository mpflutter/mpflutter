part of 'mpflutter.dart';

void build(List<String> args) {
  final target = args.length <= 1 || args[1] == 'web' ? 'web' : args[1];
  if (target == 'web') {
    _buildWeb();
  } else if (target == 'weapp') {
    _buildTaro("weapp");
  }
}

List<dynamic> subPackages() {
  if (!processArgs.contains('--subPackages')) {
    return ['main'];
  }
  final yamlConfig = loadYaml(File('pubspec.yaml').readAsStringSync());
  if (yamlConfig is Map && yamlConfig['sub_packages'] is List) {
    return yamlConfig['sub_packages'];
  }
  return ['main'];
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
