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

  static needNodeEnv() {
    switch (currentLang) {
      case Lang.zh:
        return '构建脚本需要 NodeJS 环境，请到 https://nodejs.org/ 安装。';
      default:
        return 'The build script needs NodeJS, please install via https://nodejs.org/';
    }
  }

  static building() {
    switch (currentLang) {
      case Lang.zh:
        return '正在构建...';
      default:
        return 'Building...';
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

  static selectVersionCode() {
    switch (currentLang) {
      case Lang.zh:
        return '请选择 mpflutter 版本号：';
      default:
        return 'Select the mpflutter version code:';
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
* 欢迎使用 MPFlutter 帮助中心，请选择你要解决的问题：
        ''';
      default:
        return '''
* Welcome to mpflutter help center, select the problem solver:
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

  static confirmRemoveGitOrigin() {
    switch (currentLang) {
      case Lang.zh:
        return '是否移除模板工程自带的 Git 源？';
      default:
        return 'Remove the git source from template project?';
    }
  }

  static askTemplateProjectName() {
    switch (currentLang) {
      case Lang.zh:
        return '请输入工程名称，合法字符为全小写英文和下划线：';
      default:
        return 'Enter the project name please, can only be lower-case and under-dash:';
    }
  }

  static reserveWebProject() {
    switch (currentLang) {
      case Lang.zh:
        return '该工程需要输出到 Web 吗？(如果选择否，将删除 Web 目录。)';
      default:
        return 'Will this project build to web?(If choose false, will remove web dir.)';
    }
  }

  static reserveWeappProject() {
    switch (currentLang) {
      case Lang.zh:
        return '该工程需要输出到微信小程序吗？(如果选择否，将删除 weapp 目录。)';
      default:
        return 'Will this project build to wechat miniprogram?(If choose false, will remove weapp dir.)';
    }
  }

  static fetchingVersionInfoFromRemote() {
    switch (currentLang) {
      case Lang.zh:
        return '正在获取版本信息...';
      default:
        return 'Fetching version info from remote...';
    }
  }

  static pleaseInputIndex() {
    switch (currentLang) {
      case Lang.zh:
        return '请输入序号:';
      default:
        return 'Please input the index:';
    }
  }

  static askTemplatePluginName() {
    switch (currentLang) {
      case Lang.zh:
        return '请输入扩展名称，合法字符为全小写英文和下划线：';
      default:
        return 'Enter the plugin name please, can only be lower-case and under-dash:';
    }
  }

  static pluginAlreadyExist(String name) {
    switch (currentLang) {
      case Lang.zh:
        return '扩展目录已存在，请删除 local_plugins/$name 目录后再试。';
      default:
        return 'The plugin dir already exist, delete local_plugins/$name and try again.';
    }
  }

  static useGitee() {
    switch (currentLang) {
      case Lang.zh:
        return '要使用 Gitee 源下载模板代码吗？';
      default:
        return 'Use gitee as download source?';
    }
  }

  static localPluginCreated(String name) {
    switch (currentLang) {
      case Lang.zh:
        return '''
扩展代码已生成，请进入 local_plugins/$name 目录查看。
此外，你还需要手动将扩展添加到 pubspec.yaml 项目依赖文件中。
dependencies:
  $name:
    path: local_plugins/$name
''';
      default:
        return '''
The plugin code is now ready, goto local_plugins/$name dir with checking.
And then, you need to add dependency to pubspec.yaml.
dependencies:
  $name:
    path: local_plugins/$name
''';
    }
  }

  static flutterNativeCreated() {
    switch (currentLang) {
      case Lang.zh:
        return '''
Flutter Native 工程已生成，请进入 flutter_native 目录，使用 VSCode / Xcode / Android Studio 打开对应工程，尝试构建到 iOS / Android 设备上。
构建没有问题后，你可以使用当前设备进行 Debug 和 Release 操作。
具体操作方法请进入官网 https://mpflutter.com 查阅文档。
''';

      default:
        return '''
Flutter Native project already generated.
Enter flutter_native directory, use VSCode / Xcode / Android Studio open it, try to build it.
You can use the device to debug or release after build success.
For more information, go to https://mpflutter.com read documentation.
''';
    }
  }

  static flutterNativeProjectNotExists() {
    switch (currentLang) {
      case Lang.zh:
        return 'Flutter Native 工程不存在，请先使用 help.dart 初始化。';
      default:
        return 'The Flutter Native project does not exist, please use help.dart to initialize first.';
    }
  }

  static flutterNativeBuildSuccess() {
    switch (currentLang) {
      case Lang.zh:
        return 'Flutter Native 构建完成，在 build 文件夹下是一个常规的 flutter 工程，你需要自行构建成 ipa 或 apk。';
      default:
        return 'The Flutter Native build is complete. It is a regular flutter project under the build folder. You need to build it into ipa or apk by yourself.';
    }
  }
}
