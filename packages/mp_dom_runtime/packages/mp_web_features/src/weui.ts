import { MPWebDialog } from "./web_dialog";

export const installWeui = () => {
  let shadowDiv = document.createElement("div");
  document.body.appendChild(shadowDiv);
  MPWebDialog.weuiShadowRoot = shadowDiv.attachShadow ? shadowDiv.attachShadow({ mode: "closed" }) : shadowDiv;
  const script = document.createElement("script");
  script.src = "https://res.wx.qq.com/open/libs/weuijs/1.2.1/weui.min.js";
  document.body.appendChild(script);
  const cssStyle = document.createElement("link");
  cssStyle.rel = "stylesheet";
  cssStyle.href = "https://lf3-cdn-tos.bytecdntp.com/cdn/expire-1-M/weui/2.4.4/style/weui.min.css";
  MPWebDialog.weuiShadowRoot.appendChild(cssStyle);
  (window as any).mpAttachWeuiSlider = attachWeuiSlider;
};

const attachWeuiSlider = (target: HTMLDivElement) => {
  const weuiShadowRoot = target.attachShadow ? target.attachShadow({ mode: "closed" }) : target;
  const cssStyle = document.createElement("link");
  cssStyle.rel = "stylesheet";
  cssStyle.href = "https://lf3-cdn-tos.bytecdntp.com/cdn/expire-1-M/weui/2.4.4/style/weui.min.css";
  weuiShadowRoot.appendChild(cssStyle);
  const sliderElement = document.createElement("body");
  sliderElement.setAttribute("data-weui-theme", "light");
  sliderElement.innerHTML = `<div class="weui-slider">
  <div id="sliderInner" class="weui-slider__inner">
      <div id="sliderTrack" style="width: 50%;" class="weui-slider__track"></div>
      <div role="slider" aria-label="thumb" id="sliderHandler" style="left: 50%;" class="weui-slider__handler weui-wa-hotarea"></div>
  </div>
</div>`;
  weuiShadowRoot.appendChild(sliderElement);
  setTimeout(() => {
    var totalLen = sliderElement.querySelector("#sliderInner")!.clientWidth,
      startLeft = 0,
      startX = 0;
    var sliderTrack = sliderElement.querySelector("#sliderTrack") as HTMLDivElement;
    var sliderHandler = sliderElement.querySelector("#sliderHandler") as HTMLDivElement;
    sliderHandler.addEventListener("touchstart", (e: any) => {
      startLeft = (parseInt(sliderHandler.style.left) * totalLen) / 100;
      startX = e.changedTouches[0].clientX;
    });
    sliderHandler.addEventListener("touchmove", (e: any) => {
      var dist = startLeft + e.changedTouches[0].clientX - startX,
        percent;
      dist = dist < 0 ? 0 : dist > totalLen ? totalLen : dist;
      percent = (dist / totalLen) * 100;
      sliderTrack.style.width = percent + "%";
      sliderHandler.style.left = percent + "%";
      target.dispatchEvent(new CustomEvent("change", { detail: { value: percent } } as any));
      e.preventDefault();
    });
  }, 300);
};
