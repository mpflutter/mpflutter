import 'dart:io';

import 'i18n.dart';
import 'init_android_studio.dart' as init_android_studio;
import 'init_template_project.dart' as init_template_project;
import 'upgrade.dart' as upgrade;
import 'build_web.dart' as build_web;
import 'build_weapp.dart' as build_weapp;
import 'build_swanapp.dart' as build_swanapp;
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
    'title.en': 'Upgrade MPFlutter core-libs',
    'title.zh': '升级 MPFlutter 核心库',
    'action': () {
      upgrade.main([]);
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
    'title.zh': '构建微信小程序应用',
    'action': () {
      build_weapp.main([]);
    },
  },
  {
    'title.en': 'Build Baidu-MiniProgram Application',
    'title.zh': '构建百度小程序应用',
    'action': () {
      build_swanapp.main([]);
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
