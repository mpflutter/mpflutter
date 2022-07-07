import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mpcore/mpcore.dart';

Future<Widget?>? main(List<String> args) async {
  final appConfig = PlayBoxAppConfig(
    appId: 'mpflutter_template',
    coverInfo: PlayBoxCoverInfo(
      name: '模板工程',
      color: Colors.blue,
      icon: MaterialIcons.school,
    ),
  );
  print(json.encode(appConfig));
  return null;
}
