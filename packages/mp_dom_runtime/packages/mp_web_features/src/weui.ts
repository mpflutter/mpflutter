export const installWeui = () => {
  const cssStyle = document.createElement("link");
  cssStyle.rel = "stylesheet";
  cssStyle.href =
    "https://cdn.jsdelivr.net/npm/weui@2.4.4/dist/style/weui.min.css";
  document.head.appendChild(cssStyle);
};