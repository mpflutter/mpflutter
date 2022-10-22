import { MPEnv } from "../..";
import { PlatformType } from "../../env";
import { setDOMAttribute } from "../dom_utils";
import { MPPlatformView } from "../mpkit/platform_view";

export class MPSwitch extends MPPlatformView {
  firstSetted = false;
  inputElement: any;

  constructor(document: Document, readonly initialAttributes?: any) {
    super(document, initialAttributes);
    if (__MP_MINI_PROGRAM__) {
      this.htmlElement.addEventListener("change", (e: any) => {
        this.invokeMethod("onValueChanged", { value: e.detail.value });
      });
    } else if (__MP_TARGET_BROWSER__ && __MP_TARGET_BROWSER__) {
      const weuiShadowRoot = this.htmlElement.attachShadow
        ? this.htmlElement.attachShadow({ mode: "closed" })
        : this.htmlElement;
      const cssStyle = document.createElement("link");
      cssStyle.rel = "stylesheet";
      cssStyle.href = "https://lf3-cdn-tos.bytecdntp.com/cdn/expire-1-M/weui/2.4.4/style/weui.min.css";
      weuiShadowRoot.appendChild(cssStyle);
      const switchElement = document.createElement("body");
      switchElement.setAttribute("data-weui-theme", "light");
      switchElement.innerHTML = `
      <div class="weui-cell__ft">
        <input aria-labelledby="cb_txt" id="cb" class="weui-switch" type="checkbox"/>
      </div>`;
      weuiShadowRoot.appendChild(switchElement);
      const cb = switchElement.querySelector("#cb") as HTMLInputElement;
      this.inputElement = cb;
      if (initialAttributes.defaultValue === true) {
        cb.checked = true;
      }
      cb.addEventListener("change", (e) => {
        this.invokeMethod("onValueChanged", { value: cb.checked });
      });
    }
  }

  elementType() {
    if (__MP_MINI_PROGRAM__) {
      return "wx-switch";
    } else {
      return "div";
    }
  }

  setAttributes(attributes: any) {
    super.setAttributes(attributes);
    if (__MP_MINI_PROGRAM__) {
      if (!this.firstSetted) {
        this.firstSetted = true;
        setDOMAttribute(this.htmlElement, "checked", attributes.defaultValue);
      }
      setDOMAttribute(this.htmlElement, "disabled", attributes.disabled);
      setDOMAttribute(this.htmlElement, "type", attributes.type);
      setDOMAttribute(this.htmlElement, "color", attributes.color);
    }
  }

  onMethodCall(method: string, args: any) {
    if (method === "setValue") {
      if (__MP_MINI_PROGRAM__) {
        setDOMAttribute(this.htmlElement, "checked", args.value ? "true" : "false");
      } else if (__MP_TARGET_BROWSER__) {
        (this.inputElement as HTMLInputElement).checked = args.value;
      }
    }
  }
}
