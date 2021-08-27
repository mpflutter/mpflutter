import { AncestorView, ComponentView } from "../component_view";
import { setDOMStyle } from "../dom_utils";
import { cssColor } from "../utils";

export class ColoredBox extends ComponentView {
  setAttributes(attributes: any) {
    super.setAttributes(attributes);
    setDOMStyle(this.htmlElement, {
      backgroundColor: attributes.color ? cssColor(attributes.color) : "unset",
    });
  }
}
