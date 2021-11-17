import { MPEnv, PlatformType } from "../../env";
import { setDOMAttribute, setDOMStyle } from "../dom_utils";
import { MPPlatformView } from "../mpkit/platform_view";
import { cssColorHex } from "../utils";

export class MPSlider extends MPPlatformView {
  constructor(document: Document) {
    super(document);
    if (MPEnv.platformType == PlatformType.wxMiniProgram) {
      this.htmlElement.addEventListener("change", (e: any) => {
        this.invokeMethod("onSliderChange", { value: e.detail.value });
      });
      this.htmlElement.addEventListener("changing", (e: any) => {
        this.invokeMethod("onSliderChanging", { value: e.detail.value });
      });
    }
  }

  elementType() {
    if (MPEnv.platformType == PlatformType.wxMiniProgram) {
      return "wx-slider";
    } else {
      return "div";
    }
  }

  setAttributes(attributes: any) {
    super.setAttributes(attributes);
    if (MPEnv.platformType == PlatformType.wxMiniProgram) {
      setDOMAttribute(this.htmlElement, "min", attributes.min);
      setDOMAttribute(this.htmlElement, "max", attributes.max);
      setDOMAttribute(this.htmlElement, "step", attributes.step);
      setDOMAttribute(this.htmlElement, "disabled", attributes.disabled);
      setDOMAttribute(this.htmlElement, "value", attributes.value);
      setDOMAttribute(
        this.htmlElement,
        "active-color",
        attributes.activeColor ? cssColorHex(attributes.activeColor) : null
      );
      setDOMAttribute(
        this.htmlElement,
        "background-color",
        attributes.backgroundColor ? cssColorHex(attributes.backgroundColor) : null
      );
      setDOMAttribute(this.htmlElement, "block-size", attributes.blockSize);
      setDOMAttribute(
        this.htmlElement,
        "block-color",
        attributes.blockColor ? cssColorHex(attributes.blockColor) : null
      );
      setDOMAttribute(this.htmlElement, "show-value", attributes.showValue);
    } else {
      setDOMAttribute(this.htmlElement, "class", "weui-slider-box");
    }
  }
}
