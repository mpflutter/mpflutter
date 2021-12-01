import 'dart:convert';

import 'package:mpcore/mpcore.dart';

void main(List<String> args) {
  final appConfig = WechatMiniProgramAppConfig();
  appConfig.pages = {
    '/container': WechatMiniProgramPageConfig(),
  };
  print(json.encode(appConfig));
}
