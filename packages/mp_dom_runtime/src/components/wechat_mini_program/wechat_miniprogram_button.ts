import { ComponentView } from "../component_view";
import { setDOMAttribute } from "../dom_utils";
import { MPPlatformView } from "../mpkit/platform_view";

export class WechatMiniProgramButton extends MPPlatformView {
  elementType() {
    return "button";
  }

  setAttributes(attributes: any) {
    super.setAttributes(attributes);
    setDOMAttribute(this.htmlElement, "openType", attributes.openType);
    setDOMAttribute(this.htmlElement, "appParameter", attributes.appParameter);
  }
}
