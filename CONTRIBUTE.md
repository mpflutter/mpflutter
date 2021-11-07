# 贡献代码

## 开发环境搭建

mpflutter 开发环境依赖以下工具

* macOS 
* Flutter 2.0.2+
* NodeJS 10.0+
* VSCode + Flutter 扩展

注意，目前只能在 macOS 下搭建 mpflutter 核心库的开发环境。

## 架构说明

mpflutter 源码，由两部分组成。

* Dart 端
* Native 端

Dart 端负责序列化 Element 树，响应来自 Native 的事件。

Native 端负责反序列化 Element 树，并通过 DOM / UIKit 渲染视图，响应来自 User 的事件，并发送至 Dart 端。

### Dart 端

Dart 端分别有两个子工程，在 [mpflutter/mpflutter](https://github.com/mpflutter/mpflutter) 仓库下。

`packages/flutter` 子工程存放的是 Flutter Framework 源码，fork 自官方 flutter 仓库，经过深度定制和精简。

`packages/mpcore` 子工程存放的是 MPFlutter 的核心运行时，以下是各文件夹的功能概述。

* channel - 存放 Debug / Release 模式下的消息通道代码
* components - 存放核心组件的 encoder 代码
* mpjs - 存放 mpjs 通道调用代码
* mpkit - 存放 mpkit 定制库代码

### Native 端

小程序 / Web 端由 [mp_dom_runtime](https://github.com/mpflutter/mpflutter/tree/master/packages/mp_dom_runtime) 负责渲染，具体架构请参见该仓库。

## 开发环境配置说明

### 克隆核心仓库

创建一个文件夹，一般是 `~/Document/mpflutter` ，然后在该文件夹下克隆以下仓库。

* https://github.com/mpflutter/mpflutter
* https://github.com/mpflutter/mpflutter_sample

### 安装依赖

打开 `mpflutter` 工程，在工程根目录下，使用命令行执行 `sh build.sh`。

打开 `mpflutter_sample` 工程，使用命令行执行 `dart pub get` 安装依赖。

### 尝试运行 sample 工程

使用 VSCode 打开 `mpflutter_sample` 工程，按下键盘 『F5』 键，开始 Debug。

使用 VSCode 打开 `mp_dom_runtime`，执行 `npm run build`，然后执行 `http-server -c-1`，使用浏览器打开 `sample_web` 目录。

看看 sample 工程是否正常在浏览器上运行。

### 修改 mp_dom_runtime 工程

修改代码后，重新执行 `npm run build`，在浏览器中刷新 `sample_web` 目录，查看新修改是否有效。

### 修改 mpflutter 工程

修改代码后，切换至 `mpflutter_sample` 工程，按下键盘 『F5』 键或点击 『Reload』，重新 Debug。
