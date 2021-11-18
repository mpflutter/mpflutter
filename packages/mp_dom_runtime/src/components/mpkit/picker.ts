import { MPEnv } from "../..";
import { PlatformType } from "../../env";
import { setDOMAttribute } from "../dom_utils";
import { MPPlatformView } from "../mpkit/platform_view";
export class PickerItem {
  constructor(readonly label: string, readonly disabled: boolean, readonly subItems: PickerItem[]) {}
}
export class MPPicker extends MPPlatformView {
  weuiShadowRoot: any;
  items: any;

  constructor(document: Document) {
    super(document);
    if (MPEnv.platformType === PlatformType.browser) {
      this.htmlElement.addEventListener("click", () => {
        let shadowDiv = document.createElement("div");
        document.body.appendChild(shadowDiv);
        this.weuiShadowRoot = shadowDiv.attachShadow ? shadowDiv.attachShadow({ mode: "closed" }) : shadowDiv;
        const script = document.createElement("script");
        script.src = "https://res.wx.qq.com/open/libs/weuijs/1.2.1/weui.min.js";
        document.body.appendChild(script);
        const cssStyle = document.createElement("link");
        cssStyle.rel = "stylesheet";
        cssStyle.href = "https://cdn.jsdelivr.net/npm/weui@2.4.4/dist/style/weui.min.css";
        this.weuiShadowRoot.appendChild(cssStyle);
        const div = document.createElement("body");
        div.setAttribute("data-weui-theme", "light");
        div.style.position = "absolute";
        div.style.width = "100%";
        div.style.height = "100%";
        this.weuiShadowRoot.appendChild(div);
        (window as any).weui.picker(
          (this.attributes.items as PickerItem[])?.map((it, idx) => {
            return {
              label: it.label,
              value: idx,
              disabled: it.disabled,
              children: it.subItems?.map((it, idx) => {
                return {
                  label: it.label,
                  value: idx,
                  disabled: it.disabled,
                  children: it.subItems?.map((it, idx) => {
                    return { label: it.label, value: idx, disabled: it.disabled };
                  }),
                };
              }),
            };
          }),
          {
            container: div,
            onConfirm: function (result: any) {
              console.log(result);
              this.invokeMethod("onChangeCallback", { result: result });
            },
            onClose: function () {
              div.remove();
            },
          }
        );
      });
    }
    this.htmlElement.addEventListener("change", (e: any) => {
      this.invokeMethod("onChangeCallback", { type: e.type, detail: e.detail });
    });
  }

  elementType() {
    if (MPEnv.platformType === PlatformType.browser) {
      return "div";
    } else if (MPEnv.platformType === PlatformType.wxMiniProgram) {
      return "wx-picker";
    } else {
      return "";
    }
  }

  setAttributes(attributes: any) {
    super.setAttributes(attributes);
    setDOMAttribute(this.htmlElement, "header-text", attributes.headerText);
    setDOMAttribute(this.htmlElement, "mode", attributes.mode ? attributes.mode.replace("MPPickerMode.", "") : null);
    setDOMAttribute(this.htmlElement, "disabled", attributes.disabled);
  }
}
