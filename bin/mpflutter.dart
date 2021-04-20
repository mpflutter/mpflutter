library mpflutter;

import 'dart:io';

import 'package:cli_menu/cli_menu.dart';
import 'package:io/io.dart';
import 'package:path/path.dart' as path;
import 'package:crypto/crypto.dart';
import 'package:yaml/yaml.dart';

part 'build.dart';
part 'build_web.dart';
part 'build_taro.dart';
part 'create.dart';
part 'upgrade.dart';
part 'server_ip.dart';

late List<String> processArgs;
late String codeSource;

main(List<String> args) {
  processArgs = args;
  codeSource = chooseCodeSource();
  if (args.length >= 2 && args[0] == 'create') {
    create(args);
  }
  if (args.length >= 1 && args[0] == 'upgrade') {
    upgrade(args);
  }
  if (args.length >= 1 && args[0] == 'build') {
    build(args);
  }
}

String chooseCodeSource() {
  final file = File('/tmp/.mpflutter.code.source');
  if (processArgs.contains('--useGitee')) {
    return "https://gitee.com";
  } else if (file.existsSync()) {
    return file.readAsStringSync().trim();
  } else {
    print('Pick the code source:');
    try {
      final menu = Menu(['https://github.com', 'https://gitee.com']);
      final result = menu.choose();
      file.writeAsStringSync(result.value);
      return result.value;
    } catch (e) {
      return "https://gitee.com";
    }
  }
}
