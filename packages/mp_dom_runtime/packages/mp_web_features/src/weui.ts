import { MPWebDialog } from "./web_dialog";

export const installWeui = () => {
  let shadowDiv = document.createElement("div");
  document.body.appendChild(shadowDiv);
  MPWebDialog.weuiShadowRoot = shadowDiv.attachShadow({ mode: "closed" });
  const script = document.createElement("script");
  script.src = "https://res.wx.qq.com/open/libs/weuijs/1.2.1/weui.min.js";
  document.body.appendChild(script);
  const cssStyle = document.createElement("link");
  cssStyle.rel = "stylesheet";
  cssStyle.href = "https://cdn.jsdelivr.net/npm/weui@2.4.4/dist/style/weui.min.css";
  MPWebDialog.weuiShadowRoot.appendChild(cssStyle);
};
