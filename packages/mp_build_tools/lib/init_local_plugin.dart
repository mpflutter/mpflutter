import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:cli_dialog/cli_dialog.dart';
import 'package:mp_build_tools/i18n.dart';

void main(List<String> args) {
  final pluginNameDialog = CLI_Dialog(questions: [
    [I18n.askTemplatePluginName(), 'pluginName']
  ]);
  final pluginName = pluginNameDialog.ask()['pluginName'];
  final useGiteeDialog = CLI_Dialog(booleanQuestions: [
    [I18n.useGitee(), 'Yes']
  ]);
  final useGitee = useGiteeDialog.ask()['Yes'];
  if (!File('pubspec.yaml').existsSync()) {
    throw I18n.pubspecYamlNotExists();
  }
  if (!Directory('local_plugins').existsSync()) {
    Directory('local_plugins').createSync();
  }
  if (Directory(p.join('local_plugins', pluginName)).existsSync()) {
    throw I18n.pluginAlreadyExist(pluginName);
  }
  final gitCloneResult = Process.runSync(
      'git',
      [
        'clone',
        useGitee
            ? 'https://gitee.com/mpflutter/mpflutter_plugin_template'
            : 'https://github.com/mpflutter/mpflutter_plugin_template',
        pluginName
      ],
      workingDirectory: 'local_plugins');
  if (gitCloneResult.exitCode != 0) {
    print(gitCloneResult.stdout);
    print(gitCloneResult.stderr);
    throw I18n.executeFail('git clone');
  }
  Directory(p.join('local_plugins', pluginName, '.git'))
      .deleteSync(recursive: true);
  if (File(p.join('local_plugins', pluginName, 'pubspec.yaml')).existsSync()) {
    var code = File(p.join('local_plugins', pluginName, 'pubspec.yaml'))
        .readAsStringSync();
    code = code.replaceAllMapped(RegExp('^name:[ |a-zA-Z0-9_]+', dotAll: true),
        (match) => 'name: ${pluginName}');
    File(p.join('local_plugins', pluginName, 'pubspec.yaml'))
        .writeAsStringSync(code);
  }
  if (File(p.join(
          'local_plugins', pluginName, 'lib', 'mpflutter_plugin_template.dart'))
      .existsSync()) {
    File(p.join('local_plugins', pluginName, 'lib',
            'mpflutter_plugin_template.dart'))
        .renameSync(
            p.join('local_plugins', pluginName, 'lib', pluginName + '.dart'));
  }
  print(I18n.localPluginCreated(pluginName));
}
