import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mpcore/mpcore.dart';

Future<Widget?>? main(List<String> args) async {
  final appConfig = PlayboxAppConfig(
    appId: 'mpflutter_template',
    coverInfo: PlayboxCoverInfo(
      name: '模板工程',
      color: Colors.blue,
    ),
  );
  print(json.encode(appConfig));
  return null;
}
