import { ComponentView } from "../component_view";
import { setDOMStyle } from "../dom_utils";

export class ClipOval extends ComponentView {
  setAttributes(attributes: any) {
    super.setAttributes(attributes);
    setDOMStyle(this.htmlElement, { borderRadius: "50%", overflow: "hidden" });
  }
}
