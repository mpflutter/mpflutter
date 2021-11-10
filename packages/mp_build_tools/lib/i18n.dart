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
* 欢迎使用 MPFlutter 帮助中心，请输入编号解决问题。
1. 运行 MPFlutter 诊断程序。
2. 升级 MPFlutter 核心库。
3. 构建 Web 应用。
4. 构建微信小程序应用。
5. 构建百度小程序应用.
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

  static buildSuccess(String locate) {
    switch (currentLang) {
      case Lang.zh:
        return '构建成功，产物位于 ${locate} 目录。';
      default:
        return 'Build successful, locate at ${locate} directory.';
    }
  }
}
