import { MPPlatformView } from "../../components/mpkit/platform_view";
import { setDOMAttribute, setDOMStyle } from "../dom_utils";

export class MPMiniProgramView extends MPPlatformView {
  eventListened: any = {};

  elementType() {
    return "wx-" + this.initialAttributes?.tag;
  }

  setAttributes(attributes: any) {
    super.setAttributes(attributes);
    for (const key in attributes) {
      if (key === "style") {
        setDOMStyle(this.htmlElement, attributes[key]);
      } else if (key.indexOf("on.") === 0) {
        this.addEventListener(key, attributes[key]);
      } else {
        setDOMAttribute(this.htmlElement, key, attributes[key]);
      }
    }
  }

  addEventListener(key: string, value: string[]) {
    if (this.eventListened[key]) {
      this.eventListened[key] = value;
      return;
    }
    this.eventListened[key] = value;
    this.htmlElement.addEventListener(key.replace("on.", ""), (e: any) => {
      const value = this.eventListened[key] as string[];
      if (value.length === 0) {
        this.invokeMethod(key, e.detail);
        return;
      }
      let args: any = {};
      value.forEach((argKey) => {
        args[argKey] = e.detail?.[argKey];
      });
      this.invokeMethod(key, args);
    });
  }
}
