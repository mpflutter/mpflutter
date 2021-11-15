import { setDOMAttribute } from "../dom_utils";
import { MPPlatformView } from "../mpkit/platform_view";

export class MPPicker extends MPPlatformView {
  constructor(document: Document) {
    super(document);
    this.htmlElement.addEventListener("change", (e: any) => {
      this.invokeMethod("onChangeCallback", { type: e.type, detail: e.detail });
    });
  }

  elementType() {
    return "wx-picker";
  }

  setAttributes(attributes: any) {
    super.setAttributes(attributes);
    setDOMAttribute(this.htmlElement, "header-text", attributes.headerText);
    setDOMAttribute(this.htmlElement, "mode", attributes.mode ? attributes.mode.replace("MPPickerMode.", "") : null);
    setDOMAttribute(this.htmlElement, "disabled", attributes.disabled);
  }
}
