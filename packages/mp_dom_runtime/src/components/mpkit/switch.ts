import { setDOMAttribute } from "../dom_utils";
import { MPPlatformView } from "../mpkit/platform_view";

export class MPSwitch extends MPPlatformView {
  constructor(document: Document) {
    super(document);
    this.htmlElement.addEventListener("change", (e: any) => {
      this.invokeMethod("onCallback", { value: e.detail.value });
    });
  }

  elementType() {
    return "wx-switch";
  }

  setAttributes(attributes: any) {
    super.setAttributes(attributes);
    setDOMAttribute(this.htmlElement, "checked", attributes.checked);
    setDOMAttribute(this.htmlElement, "disabled", attributes.disabled);
    setDOMAttribute(this.htmlElement, "type", attributes.type);
    setDOMAttribute(this.htmlElement, "color", attributes.color);
  }
}
