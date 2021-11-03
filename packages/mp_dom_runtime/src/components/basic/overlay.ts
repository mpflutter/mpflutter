import { MPEnv, PlatformType } from "../../env";
import { ComponentView } from "../component_view";
import { setDOMStyle } from "../dom_utils";

export class Overlay extends ComponentView {
  didSetListener = false;

  constructor(document: Document) {
    super(document);
    this.additionalConstraints = { position: "fixed" };
    setDOMStyle(this.htmlElement, {
      position: "fixed",
      zIndex: "10000",
      left: "0px",
      top: "0px",
      right: "0px",
      bottom: "0px",
      touchAction: "none",
    });
  }

  elementType() {
    return "div";
  }

  setAttributes(attributes: any) {
    super.setAttributes(attributes);
    if (attributes.onBackgroundTap && !this.didSetListener) {
      this.didSetListener = true;
      this.htmlElement.addEventListener("click", (e) => {
        if (!attributes.onBackgroundTap) return;
        this.engine.sendMessage(
          JSON.stringify({
            type: "overlay",
            message: {
              event: "onBackgroundTap",
              target: attributes.onBackgroundTap,
            },
          })
        );
        e.stopPropagation();
      });
    }
  }
}
