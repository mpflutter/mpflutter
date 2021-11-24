import { MPEnv } from "../..";
import { PlatformType } from "../../env";
import { setDOMAttribute } from "../dom_utils";
import { MPPlatformView } from "../mpkit/platform_view";
export class PickerItem {
  constructor(readonly label: string, readonly disabled: boolean, readonly subItems: PickerItem[]) {}
}
export class MPPicker extends MPPlatformView {
  weuiShadowRoot: any;
  lastItems: any;
  multiIndex: number[];

  constructor(document: Document) {
    super(document);
    this.multiIndex = [0, 0, 0];
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
        const mode = this.attributes.mode?.replace("MPPickerMode.", "") ?? "selector";
        if (mode === "date") {
          this.showDatePicker(div);
        } else {
          this.showPicker(div);
        }
      });
    }
    this.htmlElement.addEventListener("change", (e: any) => {
      const result = this.getPickerResult(e.detail.value);
      this.invokeMethod("onChangeCallback", { result: result });
    });
    this.htmlElement.addEventListener("columnchange", (e: any) => {
      this.updatePickerItem(e.detail.column, e.detail.value);
      setDOMAttribute(this.htmlElement, "range", this.lastItems);
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
    const mode = attributes.mode ? attributes.mode.replace("MPPickerMode.", "") : "selector";
    setDOMAttribute(this.htmlElement, "header-text", attributes.headerText);
    setDOMAttribute(this.htmlElement, "mode", mode);
    setDOMAttribute(this.htmlElement, "disabled", attributes.disabled);
    this.lastItems = mode === "selector" || mode === "multiSelector" ? this.getPickerItem() : null;
    setDOMAttribute(this.htmlElement, "range", this.lastItems);
    setDOMAttribute(this.htmlElement, "start", attributes.start);
    setDOMAttribute(this.htmlElement, "end", attributes.end);
    setDOMAttribute(
      this.htmlElement,
      "value",
      mode === "date" ? attributes.defaultValue?.join("-") : attributes.defaultValue
    );
    setTimeout(() => {
      const mode = attributes.mode ? attributes.mode.replace("MPPickerMode.", "") : "selector";
      setDOMAttribute(this.htmlElement, "header-text", attributes.headerText);
      setDOMAttribute(this.htmlElement, "mode", mode);
      setDOMAttribute(this.htmlElement, "disabled", attributes.disabled);
      this.lastItems = mode === "selector" || mode === "multiSelector" ? this.getPickerItem() : null;
      setDOMAttribute(this.htmlElement, "range", this.lastItems);
      setDOMAttribute(this.htmlElement, "start", attributes.start);
      setDOMAttribute(this.htmlElement, "end", attributes.end);
      setDOMAttribute(
        this.htmlElement,
        "value",
        mode === "date" ? attributes.defaultValue?.join("-") : attributes.defaultValue
      );
    }, 100);
  }

  getPickerItem(): any {
    const mode = this.attributes.mode?.replace("MPPickerMode.", "") ?? "selector";
    if (MPEnv.platformType === PlatformType.wxMiniProgram) {
      const originItems = this.attributes.items as PickerItem[];
      const firstItems = originItems?.map((it, idx) => {
        return it.label;
      });
      if (mode === "selector") {
        return firstItems;
      }
      const items = [];
      items.push(firstItems);
      const secondItems = originItems[0].subItems?.map((it, idx) => {
        return it.label;
      });
      if (secondItems) {
        items.push(secondItems);
        const thirddItems = originItems[0].subItems?.[0]?.subItems?.map((it, idx) => {
          return it.label;
        });
        if (thirddItems) {
          items.push(thirddItems);
        }
      }
      return items;
    } else {
      return (this.attributes.items as PickerItem[])?.map((it, idx) => {
        return {
          label: it.label,
          value: idx,
          disabled: it.disabled,
          children:
            mode === "selector"
              ? null
              : it.subItems?.map((it, idx) => {
                  return { label: it.label, value: idx, disabled: it.disabled };
                }),
        };
      });
    }
  }

  updatePickerItem(column: number, value: number): any {
    if (MPEnv.platformType === PlatformType.wxMiniProgram) {
      const originItems = this.attributes.items as PickerItem[];
      this.multiIndex[column] = value;
      switch (column) {
        case 0: {
          this.lastItems[1] =
            originItems[value].subItems?.map((it) => {
              return it.label;
            }) ?? [];
          this.lastItems[2] =
            originItems[value].subItems?.[0]?.subItems?.map((it) => {
              return it.label;
            }) ?? [];
          break;
        }
        case 1: {
          this.lastItems[2] =
            originItems[this.multiIndex[0]].subItems?.[value]?.subItems?.map((it) => {
              return it.label;
            }) ?? [];
          break;
        }
      }
    }
  }

  getPickerResult(e: any): any {
    const originItem = this.attributes.items as PickerItem[];
    let result = [];

    if (originItem) {
      if (typeof e === "string") {
        const firstItem = { label: originItem[parseInt(e)].label, value: parseInt(e) };
        result.push(firstItem);
        return result;
      }
      const firstIndex = e[0] ?? 0;
      const secondIndex = e[1] ?? 0;
      const thirdIndex = e[2] ?? 0;
      const firstItem = { label: originItem[firstIndex].label, value: firstIndex };
      result.push(firstItem);
      const secondLabel = originItem[firstIndex]?.subItems?.[secondIndex]?.label;
      if (secondLabel) {
        result.push({ label: secondLabel, value: secondIndex });
        const thirdLabel = originItem[firstIndex]?.subItems?.[secondIndex]?.subItems?.[thirdIndex]?.label;
        if (thirdLabel) {
          result.push({
            label: thirdLabel,
            value: thirdIndex,
          });
        }
      }
    } else {
      result = (e as string).split("-").map((it, idx) => {
        return {
          label: it,
          value: idx,
        };
      });
      console.log(result);
    }

    return result;
  }

  showPicker(div: any) {
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
        defaultValue: this.attributes.defaultValue,
        onConfirm: (result: any) => {
          this.invokeMethod("onChangeCallback", { result: result });
        },
        onClose: function () {
          div.remove();
        },
      }
    );
  }

  showDatePicker(div: any) {
    (window as any).weui.datePicker({
      start: this.attributes.start,
      end: this.attributes.end,
      defaultValue: this.attributes.defaultValue,
      onConfirm: (result: any) => {
        this.invokeMethod("onChangeCallback", { result: result });
      },
      onClose: function () {
        div.remove();
      },
      container: div,
    });
  }
}
