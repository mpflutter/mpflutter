import { setDOMAttribute, setDOMStyle } from "../dom_utils";
import { MPPlatformView } from "../mpkit/platform_view";

export class WechatMiniProgramPicker extends MPPlatformView {
  constructor(document: Document) {
    super(document);
    // this.htmlElement.addEventListener("getphonenumber", (e: any) => {
    //   this.invokeMethod("onButtonCallback", { type: e.type, detail: e.detail });
    // });
  }

  elementType() {
    return "wx-picker";
  }

  setAttributes(attributes: any) {
    super.setAttributes(attributes);
    setDOMAttribute(this.htmlElement, "header-text", attributes.headerText);
    setDOMAttribute(this.htmlElement, "mode", attributes.mode);
    setDOMAttribute(this.htmlElement, "disabled", attributes.disabled);
    setDOMAttribute(this.htmlElement, "bindcancel", attributes.bindcancel);123
    // setDOMAttribute(this.htmlElement, "appParameter", attributes.appParameter);
  }
}
