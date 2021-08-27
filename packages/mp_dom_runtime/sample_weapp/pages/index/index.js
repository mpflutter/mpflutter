// index.js
// 获取应用实例
const WXPage = require('../../mpdom.min').WXPage;
const { Engine, View } = require('../../mpdom.min');

Page(new WXPage())

// Page({
//   onLoad() {
//     const engine = new Engine();
//     engine.initWithDebuggerServerAddr('192.168.1.211:9898');
//     const document = this.selectComponent('#vdom').miniDom.document;
//     new Page(document.body, engine, {route: "/"}, document);
//     engine.start();
//   }
// })
