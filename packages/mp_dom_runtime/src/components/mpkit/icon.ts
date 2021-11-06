import { ComponentView } from "../component_view";
import { setDOMStyle } from "../dom_utils";
import { cssColor } from "../utils";

export class MPIcon extends ComponentView {
  setChildren() {}

  setAttributes(attributes: any) {
    super.setAttributes(attributes);
    setDOMStyle(this.htmlElement, {
      backgroundColor: cssColor(attributes.color),
      mask: `url(${attributes.iconUrl}) no-repeat center`,
      webkitMask: `url(${attributes.iconUrl}) no-repeat center`,
      WebkitMask: `url(${attributes.iconUrl}) no-repeat center`,
      width: "24px",
      height: "24px",
      transform: `scale(${attributes.size / 24}, ${attributes.size / 24})`,
      transformOrigin: "top left",
    } as any);
  }
}
