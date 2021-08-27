import { ComponentView } from "../component_view";
import { setDOMStyle } from "../dom_utils";

export class Visibility extends ComponentView {
  setAttributes(attributes: any) {
    super.setAttributes(attributes);
    setDOMStyle(this.htmlElement, {
      display: attributes.visible ? "contents" : "none",
    });
  }
}
