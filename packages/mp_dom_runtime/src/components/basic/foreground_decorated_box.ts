import { ComponentView } from "../component_view";
import { setDOMStyle } from "../dom_utils";
import { cssBorder, cssBorderRadius, cssColor, cssGradient, cssOffset } from "../utils";
import { DecoratedBox } from "./decorated_box";

export class ForegroundDecoratedBox extends DecoratedBox {
  decorateElement = this.document.createElement("div");

  setChildren(children: any) {
    super.setChildren(children);
    this.decorateElement.remove();
    this.htmlElement.appendChild(this.decorateElement);
  }

  setAttributes(attributes: any) {
    super.setAttributes(
      attributes,
      {
        position: "absolute",
        top: "0px",
        left: "0px",
        width: "100%",
        height: "100%",
      },
      this.decorateElement
    );
  }
}
