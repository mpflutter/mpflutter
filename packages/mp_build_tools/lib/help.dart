import 'dart:io';

import 'i18n.dart';
import 'init_android_studio.dart' as init_android_studio;
import 'init_template_project.dart' as init_template_project;
import 'init_flutter_native_project.dart' as init_flutter_native_project;
import 'upgrade.dart' as upgrade;
import 'init_local_plugin.dart' as init_local_plugin;
import 'build_web.dart' as build_web;
import 'build_weapp.dart' as build_weapp;
import 'build_flutter_native.dart' as build_flutter_native;
import 'package:cli_dialog/cli_dialog.dart';

final features = <Map>[
  {
    'title.en': 'Initialize MPFlutter Template Project',
    'title.zh': '初始化 MPFlutter 模板工程',
    'action': () {
      init_template_project.main([]);
    },
  },
  {
    'title.en': 'Initialize Android Studio Configuration File',
    'title.zh': '初始化 Android Studio 配置文件',
    'action': () {
      init_android_studio.main([]);
    },
  },
  {
    'title.en': 'Initialize Flutter Native Project',
    'title.zh': '初始化 Flutter Native 工程',
    'action': () {
      init_flutter_native_project.main([]);
    },
  },
  {
    'title.en': 'Upgrade MPFlutter core-libs',
    'title.zh': '升级 MPFlutter 核心库',
    'action': () {
      upgrade.main([]);
    },
  },
  {
    'title.en': 'Create a local plugin use template',
    'title.zh': '使用模板创建一个本地扩展',
    'action': () {
      init_local_plugin.main([]);
    },
  },
  {
    'title.en': 'Build Web Application',
    'title.zh': '构建 Web 应用',
    'action': () {
      build_web.main([]);
    },
  },
  {
    'title.en': 'Build Wechat-MiniProgram Application',
    'title.zh': '构建小程序应用（微信、字节）',
    'action': () {
      build_weapp.main([]);
    },
  },
  {
    'title.en': 'Build Flutter Native Application',
    'title.zh': '构建 Flutter Native 应用',
    'action': () {
      build_flutter_native.main([]);
    },
  },
];

void main(List<String> args) {
  String? userInput;
  if (Platform.isWindows) {
    final qDialog = CLI_Dialog(questions: [
      [
        '\n' +
            [
              ...features.asMap().map((i, e) {
                var v = '$i. ';
                if (I18n.currentLang == Lang.zh) {
                  v += e['title.zh'];
                } else {
                  v += e['title.en'];
                }
                return MapEntry(i, v);
              }).values
            ].join('\n') +
            '\n${I18n.pleaseInputIndex()}',
        'userInputIndex'
      ]
    ]);
    final userInputIndex = qDialog.ask()['userInputIndex'];
    if (userInputIndex != null) {
      final intIndex = int.tryParse(userInputIndex);
      if (intIndex != null) {
        userInput = features[intIndex]['title.en'];
      }
    }
  } else {
    final qDialog = CLI_Dialog(listQuestions: [
      [
        {
          'question': '',
          'options': [
            ...features.map<String>((e) {
              if (I18n.currentLang == Lang.zh) {
                return e['title.zh'];
              } else {
                return e['title.en'];
              }
            }),
            (() {
              if (I18n.currentLang == Lang.zh) {
                return '退出';
              } else {
                return 'Exit';
              }
            })()
          ]
        },
        'userInput'
      ]
    ]);
    userInput = qDialog.ask()['userInput'];
  }
  if (userInput != null) {
    if (userInput == '退出' || userInput == 'Exit') return;
    try {
      final entry = features.firstWhere((element) =>
          element['title.zh'] == userInput || element['title.en'] == userInput);
      (entry['action'] as Function)();
    } catch (e) {
      print(e);
    }
  }
}
