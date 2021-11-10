import 'dart:io';

import 'i18n.dart';
import 'upgrade.dart' as upgrade;
import 'build_web.dart' as build_web;
import 'build_weapp.dart' as build_weapp;
import 'build_swanapp.dart' as build_swanapp;

void main(List<String> args) {
  print(I18n.help());
  final userInput = stdin.readLineSync();
  print('请稍等...');
  if (userInput != null) {
    switch (int.tryParse(userInput)) {
      case 2:
        upgrade.main([]);
        break;
      case 3:
        build_web.main([]);
        break;
      case 4:
        build_weapp.main([]);
        break;
      case 5:
        build_swanapp.main([]);
        break;
      default:
    }
  }
}
