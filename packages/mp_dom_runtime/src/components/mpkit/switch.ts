import { MPEnv } from "../..";
import { PlatformType } from "../../env";
import { setDOMAttribute } from "../dom_utils";
import { MPPlatformView } from "../mpkit/platform_view";

export class MPSwitch extends MPPlatformView {
  constructor(document: Document) {
    super(document);
    if (MPEnv.platformType === PlatformType.wxMiniProgram) {
      this.htmlElement.addEventListener("change", (e: any) => {
        this.invokeMethod("onCallback", { value: e.detail.value });
      });
    } else if (MPEnv.platformType === PlatformType.browser) {
      const weuiShadowRoot = this.htmlElement.attachShadow
        ? this.htmlElement.attachShadow({ mode: "closed" })
        : this.htmlElement;
      const cssStyle = document.createElement("link");
      cssStyle.rel = "stylesheet";
      cssStyle.href = "https://cdn.jsdelivr.net/npm/weui@2.4.4/dist/style/weui.min.css";
      weuiShadowRoot.appendChild(cssStyle);
      const switchElement = document.createElement("body");
      switchElement.setAttribute("data-weui-theme", "light");
      switchElement.innerHTML = `
      <div class="weui-cell__ft">
        <input aria-labelledby="cb_txt" id="cb" class="weui-switch" type="checkbox"/>
      </div>`;
      weuiShadowRoot.appendChild(switchElement);
    }
  }

  elementType() {
    if (MPEnv.platformType === PlatformType.wxMiniProgram) {
      return "wx-switch";
    } else {
      return "div";
    }
  }

  setAttributes(attributes: any) {
    super.setAttributes(attributes);
    setDOMAttribute(this.htmlElement, "checked", attributes.checked);
    setDOMAttribute(this.htmlElement, "disabled", attributes.disabled);
    setDOMAttribute(this.htmlElement, "type", attributes.type);
    setDOMAttribute(this.htmlElement, "color", attributes.color);
  }
}
