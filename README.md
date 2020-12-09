# MPFlutter

MPFlutter makes it easy to build web and mini-program base on Flutter.

## 软件要求

* macOS（暂时不支持 Linux 和 Windows）
* VSCode

## 安装 Flutter 环境

在开始使用 `MPFlutter` 前，你需要先安装好 `Flutter` 环境。

请参阅[官网](https://flutter.dev)或[中国非官方镜像](https://flutter-io.cn)网站相关教程安装 `Flutter` 环境，版本要求 1.22.0+ 。

安装完成后，请在命令行执行以下命令，观察输出是否正常。

```bash
> flutter --version
Flutter 1.22.1 • channel unknown • unknown source
Framework • revision f30b7f4db9 (9 weeks ago) • 2020-10-08 10:06:30 -0700
Engine • revision 75bef9f6c8
Tools • Dart 2.10.1

> dart --version
Dart SDK version: 2.10.1 (stable) (Tue Oct 6 10:54:20 2020 +0200) on "macos_x64"
```

## 配置 pub-cache bin 到 PATH 环境变量

使用你喜爱的文本编辑器，编辑环境变量文件（在 macOS 上是 `~/.bash_profile`），添加下面一行，以便 `pub global` 中的可执行文件可以正常运行。

```bash
export PATH="/Users/<username>/.pub-cache/bin:$PATH"
```

## 安装 MPFlutter 环境

使用命令行执行以下命令。

```bash
pub global activate --source git https://github.com/mpflutter/mpflutter.git
```

然后在任意目录下，执行以下命令。

```bash
mpflutter create awesome_project
```

稍等片刻，一个崭新的 MPFlutter 工程即创建完成，使用 VSCode 打开该目录，在键盘上按 `F5` 即可开始调试（如果要求选择调试程序，请选择`Dart/Flutter`）。

不需要开启任何模拟器，只需要在 Chrome 或者 Safari 浏览器上打开 http://0.0.0.0:9898/index.html 即可预览当前开发界面。

## 构建最终产物

使用命令行进入构建最终产物的工程目录，执行以下命令。

```bash
mpflutter build
```

构建完成后，产物位于 `./build/web` 目录下。

## 升级 MPFlutter 环境

使用命令行进入需要升级环境的工程目录，执行以下命令。

```bash
mpflutter upgrade
```
