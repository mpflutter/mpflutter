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
    engine.initWithDebuggerServerAddr("127.0.0.1:9898");
    const app = new WXApp("pages/index/index", engine);
    this.app = app;
    engine.start();
  },
  globalData: {},
});
