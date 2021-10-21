import { setDOMAttribute } from "../dom_utils";
import { MPPlatformView } from "../mpkit/platform_view";

export class WechatMiniProgramButton extends MPPlatformView {
  constructor(document: Document) {
    super(document);
    this.htmlElement.addEventListener("getphonenumber", (e: any) => {
      this.invokeMethod("onButtonCallback", { type: e.type, detail: e.detail });
    });
  }

  elementType() {
    return "button";
  }

  setAttributes(attributes: any) {
    super.setAttributes(attributes);
    setDOMAttribute(this.htmlElement, "openType", attributes.openType);
    setDOMAttribute(this.htmlElement, "appParameter", attributes.appParameter);
  }
}
