import 'dart:io';

main(List<String> args) {
  if (!File('.packages').existsSync()) return;
  final stringBuffer = StringBuffer();
  final lines = File('./.packages').readAsLinesSync();
  for (final line in lines) {
    final pkgPath = line
        .replaceFirst(RegExp('.*?:'), '')
        .replaceFirst('file://', '')
        .replaceFirst('/lib/', '');
    if (File('$pkgPath/dist/index.min.js').existsSync()) {
      stringBuffer
          .writeln(File('$pkgPath/dist/index.min.js').readAsStringSync());
    }
  }
  try {
    File('web/plugins.min.js').writeAsStringSync(stringBuffer.toString());
  } catch (e) {}
  try {
    File('weapp/plugins.min.js').writeAsStringSync(
        '''var MPEnv = require("./mpdom.min").MPEnv;var pluginRegisterer = {env: MPEnv,registerPlugin: function(name, target) {MPEnv.platformGlobal()[name] = target;}};''' +
            stringBuffer.toString());
  } catch (e) {}
  try {
    File('swanapp/plugins.min.js').writeAsStringSync(stringBuffer.toString());
  } catch (e) {}
}
