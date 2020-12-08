import 'package:args/args.dart';

import 'build.dart';
import 'create.dart';
import 'upgrade.dart';

main(List<String> args) {
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
