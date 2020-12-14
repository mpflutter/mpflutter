part of 'mpflutter.dart';

void create(List<String> args) {
  final projectName = args[1];
  final dir = Directory(projectName);
  if (dir.existsSync()) {
    throw 'The project directory is not empty.';
  }
  _createFlutter(projectName);
  _createWeb(projectName);
  _replacePubspec(projectName);
  _replaceExample(projectName);
}

void _createFlutter(String projectName) {
  Process.runSync('flutter', ['create', projectName]);
  try {
    Directory(path.join(projectName, 'test')).deleteSync(recursive: true);
  } catch (e) {}
  try {
    Directory(path.join(projectName, 'ios')).deleteSync(recursive: true);
  } catch (e) {}
  try {
    Directory(path.join(projectName, 'android')).deleteSync(recursive: true);
  } catch (e) {}
  try {
    Directory(path.join(projectName, 'web')).deleteSync(recursive: true);
  } catch (e) {}
}

void _createWeb(String projectName) {
  try {
    Directory(path.join('/', 'tmp', '.mp_web_runtime'))
        .deleteSync(recursive: true);
  } catch (e) {}
  Process.runSync('git', [
    'clone',
    'https://github.com/mpflutter/mp_web_runtime.git',
    '/tmp/.mp_web_runtime',
    '--depth=1'
  ]);
  Directory(path.join(projectName, 'web')).createSync();
  copyPathSync(
    path.join('/', 'tmp', '.mp_web_runtime', 'dist'),
    path.join(projectName, 'web'),
  );
}

void _replacePubspec(String projectName) {
  File(path.join(projectName, 'pubspec.yaml')).writeAsStringSync('''
name: xxx
description: A new Flutter project.
publish_to: 'none'
version: 1.0.0+1
environment:
  sdk: ">=2.7.0 <3.0.0"
dependencies:
  flutter:
    git: https://github.com/mpflutter/flutter
  mpcore: 
    git: https://github.com/mpflutter/mpcore
  mpkit: 
    git: https://github.com/mpflutter/mpkit
dependency_overrides:
  flutter: 
    git: https://github.com/mpflutter/flutter
''');
  Process.runSync(
    'flutter',
    ['packages', 'get'],
    workingDirectory: projectName,
  );
}

void _replaceExample(String projectName) {
  File(path.join(projectName, 'lib', 'main.dart')).writeAsStringSync('''
import 'package:flutter/material.dart';
import 'package:mpkit/mpkit.dart';
import 'package:mpcore/mpcore.dart';

void main() {
  runApp(MyApp());
  MPCore().connectToHostChannel();
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MPApp(
      title: 'MPFlutter Demo',
      color: Colors.blue,
      routes: {
        '/': (context) => MyHomePage(),
      },
      navigatorObservers: [MPCore.getNavigationObserver()],
      initialRoute: MPCore.getInitialRoute(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MPScaffold(
      body: Center(
        child: Container(
          width: 200,
          height: 200,
          color: Colors.blue,
          child: Center(
            child: Text(
              'Hello, MPFlutter!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
''');
}
