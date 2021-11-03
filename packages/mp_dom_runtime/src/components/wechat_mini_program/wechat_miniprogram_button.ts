import { setDOMAttribute, setDOMStyle } from "../dom_utils";
import { MPPlatformView } from "../mpkit/platform_view";

export class WechatMiniProgramButton extends MPPlatformView {
  constructor(document: Document) {
    super(document);
    this.htmlElement.addEventListener("getphonenumber", (e: any) => {
      this.invokeMethod("onButtonCallback", { type: e.type, detail: e.detail });
    });
  }

  elementType() {
    return "wx-button";
  }

  setAttributes(attributes: any) {
    super.setAttributes(attributes);
    setDOMStyle(this.htmlElement, {
      color: 'unset',
      border: 'unset',
      fontWeight: 'unset',
      padding: '0',
      backgroundColor: 'unset',
    });
    setDOMAttribute(this.htmlElement, "open-type", attributes.openType);
    setDOMAttribute(this.htmlElement, "app-parameter", attributes.appParameter);
  }
}
