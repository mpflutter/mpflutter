# 工程架构说明

本工程是 MPFlutter 在H5、微信小程中的渲染实现。

其中，在 `packages` 中又包含了两个子仓库，`miniprogram_dom` 是微信小程序的 DOM 操作模拟实现，`mp_web_features` 是 H5 页面的功能补充实现。

## 构建方法

只能在 macOS 下构建。

### 主工程

主工程的构建不依赖任何其它仓库，依赖以下环境。

* NodeJS
* typescript (npm i -g typescript)
* browserify (npm i -g browserify)
* uglifyjs (npm i -g uglify-js)
* http-server (npm i -g http-server)

使用以下命令构建 

```
npm run build
```

### 子仓库 miniprogram_dom

使用命令行 `cd` 到 `miniprogram_dom` 目录。

使用 `npm i` 安装依赖，使用 `npm run build` 构建产物。

### 子仓库 mp_web_features

使用命令行 `cd` 到 `mp_web_features` 目录。

使用 `npm i` 安装依赖，使用 `npm run build` 构建产物。

## 调试方法

### H5

要调试 H5 应用，请在 `mp_dom_runtime` 使用 `http-server -c-1` 命令开启本地 HTTP 服务，并使用浏览器打开 `http://*:port/sample_web` 文件夹。

克隆 https://github.com/mpflutter/mpflutter_sample 仓库，并使用 VSCode F5 开启调试，使用刚刚打开的 `sample_web` 调试页面。

### 微信小程序

要调试微信小程序应用，请使用『微信开发者工具』，导入 `mp_dom_runtime/sample_weapp`，并打开小程序调试器。

克隆 https://github.com/mpflutter/mpflutter_sample 仓库，并使用 VSCode F5 开启调试，使用刚刚打开的『小程序调试器』调试页面。