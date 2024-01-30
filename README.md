# MPFlutter 2.0

MPFlutter 是一款用于构建小程序的开发框架，基于 Flutter 构建，开发体验无限接近于 Flutter 原生应用。

你可以基于 MPFlutter 开发以下平台的小程序：

- 微信小程序
- 抖音小程序（WIP - 预计 2024 年 2 月）

## 原生 Flutter 开发体验

MPFlutter 的目标是，在尽可能保留 Flutter 开发体验的同时，降低应用迁移到微信小程序的成本。

我们已经实现以下能力：

- 无缝迁移
  - 无须裁剪 Flutter Framework，你可以使用 Material / Cupertino 这些官方组件搭建 UI。
  - 自适应的构建脚本，构建小程序就像构建原生应用一般简单。
  - 完整的分包支持，适应小程序分包大小限制，静态资源、代码都可以轻松分包。
- 实时预览能力
  - 快速预览，在 Desktop 上使用 Hot Reload / Hot Restart 快速预览界面及应用逻辑
  - 跨端联调，在 Desktop 预览的基础上，可连接到微信宿主，远程调用端上接口。
- 纯正的 Flutter 
  - 支持 Flutter 3.13 以上版本，并且保证跟随官方升级而升级。
  - 完全一致的 Flutter 插件体系，开发 MPFlutter 插件就像开发 Flutter 插件一样简单。
  - 完全一致的 Pub 包管理系统，开发好的插件直接上传官方包管理平台即可使用。

总的来说，MPFlutter 就是尽可能地帮助你以低成本的方式构建微信小程序。

## 高性能的渲染体验

MPFlutter 2.0 使用 Skia + WebGL 渲染，对于 MPFlutter 1.0，性能提升是非常明显的。

具体体验在以下场景：

- 频繁更新的界面
  - 不再通过 WXML <-> JS 双向传递数据，直接通过 JS 控制 WebGL 渲染，只要 Widget 层级合理，可以做到毫秒级驱动界面更新。
  - 使用 WebGL 驱动渲染，可提升渲染缓存灵活性，你可以使用 RepaintBoundary 进一步提升界面帧率。
- 频繁的事件交互
  - 事件的接收不再单纯依赖宿主小程序的回传，MPFlutter 仅接收最基本的触摸、键盘事件，后续的事件分发全部交回 Flutter Framework 处理。
  - 这意味着你可以在小程序中获取更多、更实时的事件。
- 小游戏方案（WIP - 预计 2024 年 3 月）
  - 得益于渲染性能的提升，MPFlutter 有希望提供在微信小程序（小游戏）中使用 Flame 开发游戏的可能。

## 完整的 API 生态配套

在渲染能力以外，配套提供平台 API 封装，你不需要手动编写 Channel，MPFlutter 官方已为你完成对应封装，直接使用就可以。

## 开始体验
从《[环境安装](https://weypl4zsnv.feishu.cn/wiki/HsMzwcGKNioPlAkh9pPc8NfznIf)》开始体验 MPFlutter

## 授权

MPFlutter 2.0 版本并不是一个完全开源的项目，如果你使用 MPFlutter 开发的小程序需要用于商业目的，需要购买商用授权。

### 商业目的定义

- 面向企业内部的应用，属于商业目的，需要购买授权。
- 面向公众的应用，属于商业目的，需要购买授权。
- 目标用户只包括开发者自己，无任何营利目的，不需要购买授权。
- 目标用户是以教学演示、内部研究为目的的小程序，不需要购买授权。

### 授权购买方式

请参考《[授权购买指南](https://mpflutter.feishu.cn/wiki/KEL9wIQ7ji4ChmkFnTfcIvJPnzb)》，授权购买后我们将通过电子邮件发送授权文件给您。
