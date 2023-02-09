import { ComponentView } from "../component_view";
import { setDOMStyle } from "../dom_utils";

export class IgnorePointer extends ComponentView {
  setAttributes(attributes: any) {
    super.setAttributes(attributes);
    setDOMStyle(this.htmlElement, { pointerEvents: attributes.ignoring ? "none" : "unset" });
  }
}
