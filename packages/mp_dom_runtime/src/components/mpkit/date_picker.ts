import { MPEnv } from "../..";
import { PlatformType } from "../../env";
import { setDOMAttribute } from "../dom_utils";
import { MPPlatformView } from "../mpkit/platform_view";

export class MPDatePicker extends MPPlatformView {
  weuiShadowRoot: any;

  constructor(document: Document) {
    super(document);
    if (__MP_TARGET_BROWSER__ && __MP_TARGET_BROWSER__) {
      this.htmlElement.addEventListener("click", () => {
        let shadowDiv = document.createElement("div");
        document.body.appendChild(shadowDiv);
        this.weuiShadowRoot = shadowDiv.attachShadow ? shadowDiv.attachShadow({ mode: "closed" }) : shadowDiv;
        const script = document.createElement("script");
        script.src = "https://res.wx.qq.com/open/libs/weuijs/1.2.1/weui.min.js";
        document.body.appendChild(script);
        const cssStyle = document.createElement("link");
        cssStyle.rel = "stylesheet";
        cssStyle.href = "https://lf3-cdn-tos.bytecdntp.com/cdn/expire-1-M/weui/2.4.4/style/weui.min.css";
        this.weuiShadowRoot.appendChild(cssStyle);
        const div = document.createElement("body");
        div.setAttribute("data-weui-theme", "light");
        div.style.position = "absolute";
        div.style.width = "100%";
        div.style.height = "100%";
        this.weuiShadowRoot.appendChild(div);
        this.showDatePicker(div);
      });
    } else if (__MP_MINI_PROGRAM__) {
      this.htmlElement.addEventListener("change", (e: any) => {
        this.invokeMethod("callbackResult", { value: e.detail.value.split("-").map((it: string) => parseInt(it)) });
      });
    }
  }

  elementType() {
    if (__MP_MINI_PROGRAM__) {
      return "wx-picker";
    }
    return "div";
  }

  setAttributes(attributes: any) {
    super.setAttributes(attributes);
    setDOMAttribute(this.htmlElement, "header-text", attributes.headerText);
    setDOMAttribute(this.htmlElement, "mode", "date");
    setDOMAttribute(this.htmlElement, "start", attributes.start);
    setDOMAttribute(this.htmlElement, "end", attributes.end);
    setDOMAttribute(this.htmlElement, "value", attributes.defaultValue);
  }

  showDatePicker(div: any) {
    (window as any).weui.datePicker({
      start: this.attributes.start,
      end: this.attributes.end,
      defaultValue: this.attributes.defaultValue.split("-").map((it: string) => parseInt(it)),
      onConfirm: (result: any) => {
        this.invokeMethod("callbackResult", { value: result?.map((it: any) => it.value) });
      },
      onClose: function () {
        div.remove();
      },
      container: div,
    });
  }
}
