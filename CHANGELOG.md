# Change Log

## 2.5.0 

feat:
- 新增微信小游戏支持。
- 新增 MPFlutterNetworkImage 用于修正 Flutter Web 无 LoadingBuilder 的支持。

## 2.4.0

feat: 
- 新增无字体渲染能力的 Skia CanvasKit 产物，并且在 MiniTex 启用的情况下，可以使用该产物。
- 新增 main.mpflutter.dart 分包策略，默认 main.dart.js 将不大于 700K。
- 智能分包策略调整，在主包大小保持 2M 的情况下，去除不必要的子分包。

## 2.3.2

fix:
- TextField 设置 keyboardType 不生效的问题
- 修复微信小程序在 Windows / macOS 微信上无法运行的问题（关联微信官方 BUG ）
- (MiniTex) 目标字体不存在内置字体时，直接使用 MiniTex 进行渲染。
- 修复 viewPadding 数值不正确导致安全区域异常的问题。
- 修复 HTTP 空返回值导出请求异常的问题。
- 修复 Editable inputFormatter 和 enable 属性无效的问题。
- 修复 flutter_widget_from_html_core 无法使用的问题。
- 新增 MPFlutterImageEncoder.encodeToFilePath 和 MPFlutterImageEncoder.encodeToBase64。

## 2.3.0

fix:
- frameOnWindow x and y nan issue

feat:
- 添加 MiniTex 文本渲染器
- mpflutter_build_tools 强制 Flutter SDK 版本检测

## 2.2.0

fix:
- PlatformView 无法显示的问题。【已发布至  mpflutter_build_tools: 2.1.3 】
- 使用 GetConnect 请求时，Response 内容为空的问题。【已发布至  mpflutter_build_tools: 2.1.3 】

feat:
- 优化 Skia CanvasKit 产物大小

## 2.1.2

fix:
- MPFlutterWechatAppShareManager 未正确拼接分享参数
- 同一页面多个 PlatformView 无法同时响应触摸

## 2.1.0

fix:
- mpflutter_wechat_api Array 类型统一修改为 List
- mpflutter_wechat_api IncludePointsOption set points 缺失

feature:
- 新增 Image 解码器
- 新增 Image 编码器
- 新增分享朋友圈、收藏支持
- 新增 DarkMode 支持

## 2.0.2

- fix: Windows 构建小程序，资源分包存在问题
- fix: 小程序启动过程可能有黑色闪屏
- fix: Hot Reload 无法使用
- feat: 内置 brotli 于 mpflutter_build_tools 中，优先使用这个内置的工具。

## 2.0.0

MPFlutter 2.0.0 正式发布

## 2.0.0-alpha.7

feat: 添加 PlatformView 支持
feat: 添加 Flutter Plugin 支持
feat: 添加微信分享等能力支持
feat: 添加 Hot Reload 联机调试支持

## 2.0.0-alpha.6

- feat: 添加微信小程序插件 & PlatformView 支持
- fix: 修正 MediaQuery 问题

## 2.0.0-alpha.4
- fix: newObject with args.
- feat: add arraybuffer utils.

## 2.0.0-alpha.2
Rename to mpflutter_core.

## 2.0.0-alpha.1

Draft mpflutter 2.0 first alpha version.
