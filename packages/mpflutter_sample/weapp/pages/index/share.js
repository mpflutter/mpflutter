// share.js
// 获取应用实例
const WXPage = require('../../mpdom.min').WXPage;

const thePage = new WXPage;
thePage.kboneRender = require('../../kbone/miniprogram-render/index')
thePage.darkModeStyle.naviBarBackgroundColor = "#222222";
thePage.darkModeStyle.naviBarFrontColor = "#ffffff";
Page(thePage);
