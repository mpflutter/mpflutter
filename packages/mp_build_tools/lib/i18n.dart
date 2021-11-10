import 'dart:io';

enum Lang {
  en,
  zh,
}

class I18n {
  static Lang currentLang = (() {
    if (Platform.localeName.contains('zh')) {
      return Lang.zh;
    } else {
      return Lang.en;
    }
  })();

  static pubspecYamlNotExists() {
    switch (currentLang) {
      case Lang.zh:
        return 'pubspec.yaml 文件不存在，请确认您当前处于 mpflutter 工程根目录。';
      default:
        return 'The pubspec.yaml not exists, confirm you are in the mpflutter project root dir.';
    }
  }

  static executeFail(String process) {
    switch (currentLang) {
      case Lang.zh:
        return '${process} 命令执行失败。';
      default:
        return '${process} execute failed.';
    }
  }

  static currentMasterVersion() {
    switch (currentLang) {
      case Lang.zh:
        return '当前主干版本';
      default:
        return 'Current master version';
    }
  }

  static currentReleaseVersion() {
    switch (currentLang) {
      case Lang.zh:
        return '当前发布版本';
      default:
        return 'Current release version';
    }
  }

  static retryWithVersionCode() {
    switch (currentLang) {
      case Lang.zh:
        return '请添加版本标识，以执行版本更新，以下是例子。';
      default:
        return 'Retry with version code to upgrade for example.';
    }
  }

  static successfulUpgrade(String name) {
    switch (currentLang) {
      case Lang.zh:
        return '成功更新${name}';
      default:
        return 'Successful upgrade ${name}.';
    }
  }

  static help() {
    switch (currentLang) {
      case Lang.zh:
        return '''
* Welcome to mpflutter help center, enter the number to solve problem.
1. Run MPFlutter Doctor.
2. Upgrade MPFlutter core-libs.
3. Build Web Application.
4. Build Wechat-MiniProgram Application.
5. Build Baidu-MiniProgram Application.
        ''';
      default:
        return '''
* Welcome to mpflutter help center, enter the number to solve problem.
1. Run MPFlutter Doctor.
2. Upgrade MPFlutter core-libs.
3. Build Web Application.
4. Build Wechat-MiniProgram Application.
5. Build Baidu-MiniProgram Application.
        ''';
    }
  }
}
