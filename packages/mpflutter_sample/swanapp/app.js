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
      engine.initWithCodeBlock(function () {
        require("./main.dart.js").main();
      });
    }
    const app = new WXApp("pages/index/index", engine);
    this.app = app;
    this.Base64 = require("./base64.min");
    engine.start();
  },
  globalData: {},
});
