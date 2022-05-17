import { MPEnv, PlatformType } from "../../env";
import { setDOMAttribute, setDOMStyle } from "../dom_utils";
import { MPPlatformView } from "../mpkit/platform_view";

export class MPSlider extends MPPlatformView {
  firstSetup = true;
  sliderElement: any;
  constructor(document: Document) {
    super(document);
    this.htmlElement.addEventListener("change", (value: any) => {
      this.invokeMethod("onValueChanged", { value: value.detail.value });
    });
    if (__MP_MINI_PROGRAM__) {
      this.htmlElement.addEventListener("changing", (value: any) => {
        this.invokeMethod("onValueChanged", { value: value.detail.value });
      });
      setDOMStyle(this.htmlElement, { margin: "0", marginTop: "8px" });
    } else if (__MP_TARGET_BROWSER__ && __MP_TARGET_BROWSER__) {
      const weuiShadowRoot = this.htmlElement.attachShadow
        ? this.htmlElement.attachShadow({ mode: "closed" })
        : this.htmlElement;
      const cssStyle = document.createElement("link");
      cssStyle.rel = "stylesheet";
      cssStyle.href = "https://lf3-cdn-tos.bytecdntp.com/cdn/expire-1-M/weui/2.4.4/style/weui.min.css";
      weuiShadowRoot.appendChild(cssStyle);
      this.sliderElement = document.createElement("body");
      this.sliderElement.setAttribute("data-weui-theme", "light");
      weuiShadowRoot.appendChild(this.sliderElement);
    }
  }

  elementType() {
    if (__MP_MINI_PROGRAM__) {
      return "wx-slider";
    }
    return "div";
  }

  setAttributes(attributes: any) {
    super.setAttributes(attributes);
    if (__MP_MINI_PROGRAM__) {
      setDOMAttribute(this.htmlElement, "min", attributes.min);
      setDOMAttribute(this.htmlElement, "max", attributes.max);
      setDOMAttribute(this.htmlElement, "step", attributes.step);
      setDOMAttribute(this.htmlElement, "disabled", attributes.disabled);
      if (this.firstSetup) {
        setDOMAttribute(this.htmlElement, "value", attributes.defaultValue);
      }
      this.firstSetup = false;
    } else if (__MP_TARGET_BROWSER__ && __MP_TARGET_BROWSER__ && this.firstSetup) {
      this.sliderElement.innerHTML = `<div class="weui-slider">
        <div id="sliderInner" class="weui-slider__inner">
          <div id="sliderTrack" style="width: 0%;" class="weui-slider__track"></div>
          <div role="slider" aria-label="thumb" id="sliderHandler" style="left: 0%;" class="weui-slider__handler weui-wa-hotarea"></div>
        </div>
      </div>`;
      if (attributes.disabled !== true) {
        const min = attributes.min ?? 0;
        const max = attributes.max ?? 100;
        setTimeout(() => {
          let totalLen = this.sliderElement.querySelector("#sliderInner")!.clientWidth,
            startLeft = 0,
            startX = 0;
          const sliderHandler = this.sliderElement.querySelector("#sliderHandler") as HTMLDivElement;
          sliderHandler.addEventListener("touchstart", (e: any) => {
            startLeft = (parseInt(sliderHandler.style.left) * totalLen) / 100;
            startX = e.changedTouches[0].clientX;
          });
          sliderHandler.addEventListener("touchmove", (e: any) => {
            let dist = startLeft + e.changedTouches[0].clientX - startX;
            dist = Math.max(0, Math.min(totalLen, dist));
            const percent = dist / totalLen;
            const value = min + percent * (max - min);
            const sValue = (value - min) % (this.attributes.step ?? 1);
            const stepedValue = value - sValue;
            this.resetSliderValue(value);
            this.htmlElement.dispatchEvent(
              new CustomEvent("change", {
                detail: {
                  value: stepedValue,
                },
              } as any)
            );
            e.preventDefault();
          });
        }, 300);
        if (this.firstSetup) {
          this.resetSliderValue(attributes.defaultValue);
        }
        this.firstSetup = false;
      }
    }
  }

  resetSliderValue(value: number) {
    if (!__MP_TARGET_BROWSER__) return;
    const min = this.attributes.min ?? 0;
    const max = this.attributes.max ?? 100;
    const sValue = (value - min) % (this.attributes.step ?? 1);
    const stepedValue = value - sValue;
    let percent = (stepedValue - min) / (max - min);
    let sliderTrack = this.sliderElement.querySelector("#sliderTrack") as HTMLDivElement;
    let sliderHandler = this.sliderElement.querySelector("#sliderHandler") as HTMLDivElement;
    sliderTrack.style.width = (percent * 100).toFixed(0) + "%";
    sliderHandler.style.left = (percent * 100).toFixed(0) + "%";
  }

  onMethodCall(method: string, params: any) {
    if (method === "setValue") {
      const value = params?.value;
      if (typeof value === "number") {
        if (__MP_MINI_PROGRAM__) {
          this.htmlElement.setAttribute("value", value as any);
        } else if (__MP_TARGET_BROWSER__ && __MP_TARGET_BROWSER__) {
          this.resetSliderValue(params.value);
        }
      }
    }
  }
}
