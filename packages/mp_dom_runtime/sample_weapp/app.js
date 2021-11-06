// app.js
App({
  onLaunch() {
    this.mpDEBUG = true;
    const { MPEnv, Engine, WXApp } = require("./mpdom.min");
    MPEnv.platformAppInstance = this;
    try {
      require("./plugins.min");
    } catch (error) {}
    const engine = new Engine();
    engine.initWithDebuggerServerAddr("192.168.1.111:9898");
    const app = new WXApp("pages/index/index", engine);
    this.app = app;
    engine.start();
  },
  globalData: {},
});
