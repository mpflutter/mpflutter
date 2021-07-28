# MPFlutter

[官方网站](https://mpflutter.com/)

`MPFlutter` 是一个渐进式 Flutter 开发框架。

你可以基于 Flutter 开发微信小程序、H5、iOS、Android应用，开发者毋需学习传统的 CSS / HTML / JavaScript，也不需要学习 iOS / Android UIKit 知识，使用 Dart / Flutter Framework 即可完成整个 App 开发。

## 渐进式的定义

何谓渐进式？

渐进式是被设计为可以自底向上逐层应用的架构。基于渐进式开发框架，你可以在某一个 View 中使用 Flutter 开发，而不需要一整个应用替换成 Flutter。当一切就绪时，渐进式开发框架支持你逐层替换，从 View 到 Page，从 Page 到 App。

MPFlutter 通过以下组件实现渐进式架构：

* Engine - 用于支撑单个实例运行，其中运行有孤立的 JSContext 实例。
* App - 用于以 App 级别执行应用，支持跨页面路由。
* Page - 用于以 Page 级别执行应用，不支持路由。

## 起步

尝试 MPFlutter 最简单的方法是使用 [GitPod Hello World 例子](./gitpod)，你可以在 Chrome 浏览器新标签页中打开它，跟着例子学习一些基础的 Dart 语法，以及 Flutter 布局知识。

[安装教程](./install)给出了更具体的 MPFlutter 使用方式，你可以基于安装教程一步一步地搭建开发环境。

## 学习资源

如果你是一名 Dart / Flutter Framework 新手，可以参考以下网站，这些网站有非常生动、具体的教程。

[Flutter 官方网站](https://flutter.dev)

[Dart 官方网站](https://dart.dev)

[Flutter 社区中文资源](https://flutter-io.cn)

[Dart 中文文档](https://dart.cn)
