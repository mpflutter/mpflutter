import { MPEnv } from "../..";
import { PlatformType } from "../../env";
import { setDOMAttribute } from "../dom_utils";
import { MPPlatformView } from "../mpkit/platform_view";
export class PickerItem {
  constructor(readonly label: string, readonly disabled: boolean, readonly subItems: PickerItem[]) {}
}
export class MPPicker extends MPPlatformView {
  weuiShadowRoot: any;
  multiIndex: number[];

  constructor(document: Document, readonly initialAttributes?: any) {
    super(document, initialAttributes);
    this.multiIndex = initialAttributes?.defaultValue ?? [0, 0, 0];
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
        this.showPicker(div);
      });
    }
    this.htmlElement.addEventListener("change", (e: any) => {
      this.invokeMethod("callbackResult", {
        value:
          typeof e.detail.value === "string" || typeof e.detail.value === "number"
            ? [parseInt(e.detail.value)]
            : e.detail.value,
      });
    });
    this.htmlElement.addEventListener("columnchange", (e: any) => {
      this.updatePickerItem(e.detail.column, e.detail.value);
      setDOMAttribute(this.htmlElement, "range", this.getPickerItem());
    });
  }

  elementType() {
    if (__MP_MINI_PROGRAM__) {
      return "wx-picker";
    }
    return "div";
  }

  setAttributes(attributes: any) {
    super.setAttributes(attributes);
    if (__MP_MINI_PROGRAM__) {
      setDOMAttribute(this.htmlElement, "header-text", attributes.headerText);
      setDOMAttribute(this.htmlElement, "mode", attributes.column > 1 ? "multiSelector" : "selector");
      setDOMAttribute(this.htmlElement, "disabled", attributes.disabled);
      setDOMAttribute(this.htmlElement, "range", this.getPickerItem());
      setDOMAttribute(this.htmlElement, "value", this.multiIndex);
    }
  }

  getPickerItem(): any {
    if (__MP_MINI_PROGRAM__) {
      const originItems = this.attributes.items as PickerItem[];
      let items: any[] = [];
      if (this.attributes.column === 1) {
        items = originItems.map((it) => it.label);
      } else {
        items.push(originItems.map((it) => it.label));
        if (this.attributes.column >= 2) {
          try {
            items.push(originItems[this.multiIndex[0]].subItems.map((it) => it.label));
          } catch (error) {
            items.push([]);
          }
        }
        if (this.attributes.column >= 3) {
          try {
            items.push(originItems[this.multiIndex[0]].subItems[this.multiIndex[1]].subItems.map((it) => it.label));
          } catch (error) {
            items.push([]);
          }
        }
      }
      return items;
    }
  }

  updatePickerItem(column: number, value: number): any {
    if (__MP_MINI_PROGRAM__) {
      this.multiIndex[column] = value;
    }
  }

  showPicker(div: any) {
    if (!__MP_TARGET_BROWSER__) return;
    (window as any).weui.picker(
      (this.attributes.items as PickerItem[])?.map((it, idx) => {
        return {
          label: it.label,
          value: idx,
          disabled: it.disabled,
          children: it.subItems
            ? it.subItems?.map((it, idx) => {
                return {
                  label: it.label,
                  value: idx,
                  disabled: it.disabled,
                  children: it.subItems
                    ? it.subItems?.map((it, idx) => {
                        return { label: it.label, value: idx, disabled: it.disabled };
                      })
                    : this.attributes.column >= 3
                    ? [{ label: "" }]
                    : undefined,
                };
              })
            : this.attributes.column >= 2
            ? [{ label: "" }]
            : undefined,
        };
      }),
      {
        container: div,
        defaultValue: this.multiIndex,
        onConfirm: (result: any) => {
          this.multiIndex = result.map((it: any) => it.value);
          this.invokeMethod("callbackResult", { value: result.map((it: any) => it.value) });
        },
        onClose: function () {
          div.remove();
        },
      }
    );
  }
}
