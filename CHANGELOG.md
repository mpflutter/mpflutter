# Change Log

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