App({
    onLaunch(options) {
        global.mpDEBUG = true;
        try {
        require("./plugins.min");
        } catch (error) {}
        const { Engine, WXApp } = require("./mpdom.min");
        const engine = new Engine();
        engine.initWithDebuggerServerAddr("192.168.1.158:9898");
        const app = new WXApp("pages/index/index", engine);
        global.app = app;
        engine.start();
    },
});
