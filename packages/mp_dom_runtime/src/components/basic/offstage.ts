import { ComponentView } from "../component_view";
import { setDOMStyle } from "../dom_utils";

export class Offstage extends ComponentView {
  setAttributes(attributes: any) {
    super.setAttributes(attributes);
    setDOMStyle(this.htmlElement, {
      display: attributes.offstage ? "none" : "unset",
    });
  }
}
