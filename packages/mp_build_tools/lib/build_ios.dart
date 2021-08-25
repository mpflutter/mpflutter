import 'dart:io';

import './build_mpk.dart' as build_mpk;

main(List<String> args) {
  build_mpk.main(args);
  File('./build/app.mpk').copySync('./iosproj/app.mpk');
  print('''
  Build finish, and you need to open iosproj in XCode, archive project by yourself, or you can change the 'dev' options to NO for preview. [EN]
  构建完成，你需要使用 XCode 打开 iosproj，自行执行 archive 打包，你也可以将 dev 选项设置为 NO 预览应用。[ZH]
  ''');
}
