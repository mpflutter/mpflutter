import { ComponentView } from "../component_view";
import { setDOMStyle } from "../dom_utils";

export class Transform extends ComponentView {
  setAttributes(attributes: any) {
    super.setAttributes(attributes);
    setDOMStyle(this.htmlElement, { transform: attributes.transform });
  }
}
