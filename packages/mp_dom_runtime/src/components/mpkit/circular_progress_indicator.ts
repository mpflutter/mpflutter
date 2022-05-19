import { ComponentView } from "../component_view";
import { setDOMStyle } from "../dom_utils";
import { cssColor } from "../utils";

const iconUrl = "https://dist.mpflutter.com/res/spinner.svg";

export class MPCircularProgressIndicator extends ComponentView {
  setChildren() {}

  setAttributes(attributes: any) {
    super.setAttributes(attributes);
    const size = attributes.size ?? 36;
    setDOMStyle(this.htmlElement, {
      backgroundColor: cssColor(attributes.color),
      mask: `url(${iconUrl}) no-repeat center`,
      webkitMask: `url(${iconUrl}) no-repeat center`,
      WebkitMask: `url(${iconUrl}) no-repeat center`,
      width: "65px",
      height: "65px",
      transform: `scale(${size / 65}, ${size / 65})`,
      transformOrigin: "top left",
    } as any);
  }
}
