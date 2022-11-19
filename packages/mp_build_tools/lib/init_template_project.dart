import 'dart:io';

import 'package:cli_dialog/cli_dialog.dart';
import 'package:mp_build_tools/i18n.dart';

void main(List<String> args) {
  final removeGitRemoteDialog = CLI_Dialog(booleanQuestions: [
    [I18n.confirmRemoveGitOrigin(), 'Yes']
  ]);
  final removeGitRemoteAnswer = removeGitRemoteDialog.ask()['Yes'];
  if (removeGitRemoteAnswer) {
    Process.runSync('git', ['remote', 'remove', 'origin']);
  }
  final projectNameDialog = CLI_Dialog(questions: [
    [I18n.askTemplateProjectName(), 'projectName']
  ]);
  final projectName = projectNameDialog.ask()['projectName'];
  if (File('pubspec.yaml').existsSync()) {
    var code = File('pubspec.yaml').readAsStringSync();
    code = code.replaceAllMapped(RegExp('^name:[ |a-zA-Z0-9_]+', dotAll: true),
        (match) => 'name: ${projectName}');
    File('pubspec.yaml').writeAsStringSync(code);
  }
  if (File('lib/main.dart').existsSync()) {
    var code = File('lib/main.dart').readAsStringSync();
    code = code.replaceAll('mpflutter_template', projectName);
    File('lib/main.dart').writeAsStringSync(code);
  }

  if (Directory('.github').existsSync()) {
    Directory('.github').deleteSync(recursive: true);
  }
  final reserveWebProjectDialog = CLI_Dialog(booleanQuestions: [
    [I18n.reserveWebProject(), 'Yes']
  ]);
  if (Directory('web').existsSync()) {
    final reserveWebProjectAnswer = reserveWebProjectDialog.ask()['Yes'];
    if (!reserveWebProjectAnswer) {
      Directory('web').deleteSync(recursive: true);
    }
  }
  if (Directory('weapp').existsSync()) {
    final reserveWeappProjectDialog = CLI_Dialog(booleanQuestions: [
      [I18n.reserveWeappProject(), 'Yes']
    ]);
    final reserveWeappProjectAnswer = reserveWeappProjectDialog.ask()['Yes'];
    if (!reserveWeappProjectAnswer) {
      Directory('weapp').deleteSync(recursive: true);
    }
  }
}
