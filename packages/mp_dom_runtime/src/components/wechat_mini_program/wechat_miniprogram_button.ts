import { setDOMAttribute } from "../dom_utils";
import { MPPlatformView } from "../mpkit/platform_view";

export class WechatMiniProgramButton extends MPPlatformView {
  constructor(document: Document) {
    super(document);
    (this.htmlElement as any).onbuttoncallback = (value: string) => {
      this.invokeMethod("onButtonCallback", JSON.parse(value));
    };
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
