import { AncestorView, ComponentView } from "../component_view";
import { setDOMStyle } from "../dom_utils";

export class Opacity extends ComponentView {
  setAttributes(attributes: any) {
    super.setAttributes(attributes);
    setDOMStyle(this.htmlElement, { opacity: attributes.opacity.toString() });
  }
}

export class OpacityAncestor extends AncestorView {
  setAttributes(attributes: any) {
    super.setAttributes(attributes);
    if (!this.target.ancestorStyle.opacity) {
      this.target.ancestorStyle.opacity = 1.0;
    }
    this.target.ancestorStyle.opacity *= attributes.opacity;
  }
}
