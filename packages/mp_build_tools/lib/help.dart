import 'dart:io';

import 'i18n.dart';

void main(List<String> args) {
  print(I18n.help());
  final userInput = stdin.readLineSync();
  print(userInput);
}
