import './js/libs/weapp-adapter'
import './js/libs/symbol'

const ctx = canvas.getContext('2d')

export default class Main {

  constructor() {
    this.restart();
  }

  restart() {

    this.aniId = 0
    window.mpDEBUG = true;
    const { Engine, Page, CanvasApp } = require("./js/mpdom.min");

    var engine = new Engine();
    var dev = true;
    if (dev) {
      // engine.initWithDebuggerServerAddr(new URL(window.location.href).hostname + ':9898');
      engine.initWithDebuggerServerAddr('127.0.0.1:9898');
      engine.start();
    } else {
      Engine.codeBlockWithCodePath('main.dart.js').then(function (codeBlock) {
        engine.initWithCodeBlock(codeBlock);
        engine.start();
      });
    }
    var app = new CanvasApp(ctx, engine);
    app.setupFirstPage();
  }

}

new Main()
