# MPFlutter 工程模板

本仓库是 MPFlutter 工程壳模板，你可以下载本仓库，并根据需要移除不必要的部分，然后开始开发。

在根目录下，iosproj 是 iOS 工程，weapp 是微信小程序工程，web 是 H5 工程，如果你不需要对应的输出端，可以移除。

## 环境准备

至少需要以下开发环境

- 操作系统：macOS / Windows / Linux 任一操作系统
- 代码编辑器：VSCode
- VSCode 扩展：Dart 和 Flutter 
- Flutter 开发环境
- Chrome 浏览器
- Node 16

Flutter 开发环境可以在 https://flutter.dev 或 https://flutter-io.cn 下载安装。

Node 16可以通过[nvm](https://github.com/nvm-sh/nvm#installing-and-updating)得到

## 开发

1. 使用 Git clone 或直接下载本仓库，使用 VSCode 打开本仓库根目录。
2. 执行主目录的build.sh脚本
3. 使用命令行，locate 到本仓库根目录，执行命令 `dart pub get`。
4. 按下键盘上的 'F5' 键，开始调试，在 VSCode 的调试控制台上出现如下输出。

```
Connecting to VM Service at http://127.0.0.1:61276/OgoUGNgV_fE=/
lib/main.dart: Warning: Interpreting this as package URI, 'package:mpflutter_template/main.dart'.
Hot reloading enabled
Listening for file changes at ./lib
Serve on 0.0.0.0:9898
Use browser open http://0.0.0.0:9898/index.html or use MiniProgram Developer Tools import './dist/weapp' for dev.
```

5. 打开 Chrome 浏览器，输入网址 http://127.0.0.1:9898 ，如无意外，你将看到 Hello, MPFlutter! 提示。
6. 在 VSCode 中打开 `lib/main.dart`，尝试修改 Hello, MPFlutter! 文本，并保存，看看是否可以实现 Hot-Reload?
7. 如果没有问题，你可以在 lib 目录下开展业务开发了。

### 微信小程序

如果需要在微信小程序中实现边开发边调试能力，可以直接将 weapp 目录导入到『微信开发者工具』中。

你也可以通过修改 weapp 目录下的文件，实现定制化功能。

### iOS

如果需要在 iOS 中实现边开发边调试能力，可以使用 XCode 直接打开 iosproj 目录下的 `template.xcworkspace`，使用模拟器运行应用。

你也可以通过修改 iosproj 目录下的文件，实现定制化功能。

## 构建

### H5

使用操作系统的命令行工具，locate 到工程根目录，执行以下命令。

```sh
dart scripts/build_web.dart
```

执行完成后，H5 产物在 build 目录下，你可以上传到 HTTP 服务器上使用。

### 微信小程序

使用操作系统的命令行工具，locate 到工程根目录，执行以下命令。

```sh
dart scripts/build_weapp.dart
```

执行完成后，微信小程序产物在 build 目录下，你可以打开『微信开发者工具』，导入 build 目录，进一步编译、测试并上传审核。

### iOS

使用操作系统的命令行工具，locate 到工程根目录，执行以下命令。

```sh
dart scripts/build_ios.dart
```

执行完成后，使用 XCode 打开 iosproj/template.xcworkspace，进一步构建 ipa 包，并上传到 AppStore 审核。

注意：iOS 工程需要使用 CocoaPods 安装依赖。

## 升级 mpflutter 版本

在工程根目录执行 `dart scripts/upgrade.dart`，按照提示即可升级 mpflutter 至最新版本。