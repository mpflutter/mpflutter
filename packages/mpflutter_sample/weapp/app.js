// app.js
App({
  onLaunch() {
    const { MPEnv, Engine, WXApp } = require("./mpdom.min");
    MPEnv.platformAppInstance = this;
    try {
      require("./plugins.min");
    } catch (error) {}
    const engine = new Engine();
    var dev = true;
    if (dev) {
      engine.initWithDebuggerServerAddr("127.0.0.1:9898");
    } else {
      engine.initWithCodeBlock(Engine.codeBlockWithFile("./main.dart.js"));
    }
    const app = new WXApp("pages/index/index", engine);
    this.app = app;
    engine.start();
    try {
      // 为了防止 main.dart.js 和 mp-custom-components.js 被微信开发者工具过滤，在这里 require 一下。
      require("./main.dart");
      require("./mp-custom-components");
    } catch (error) {}
  },
  globalData: {},
});
