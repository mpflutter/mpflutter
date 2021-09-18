import { MPEnv, PlatformType } from "../../env";
import { ComponentView } from "../component_view";
import { setDOMStyle } from "../dom_utils";
import { cssColor } from "../utils";

export class Overlay extends ComponentView {
  elementType() {
    if (
      MPEnv.platformType == PlatformType.wxMiniProgram ||
      MPEnv.platformType == PlatformType.swanMiniProgram
    ) {
      return "catchmove";
    } else {
      return "div";
    }
  }

  setAttributes(attributes: any) {
    super.setAttributes(attributes);
    if (
      MPEnv.platformType == PlatformType.wxMiniProgram ||
      MPEnv.platformType == PlatformType.swanMiniProgram
    ) {
    } else {
      this.htmlElement.addEventListener("touchmove", (e) => {
        e.preventDefault();
      });
    }
    this.additionalConstraints = { position: "fixed" };
    setDOMStyle(this.htmlElement, {
      position: "fixed",
      zIndex: "10000",
    });
    if (attributes.onBackgroundTap) {
      this.htmlElement.onclick = () => {
        this.engine.sendMessage(
          JSON.stringify({
            type: "overlay",
            message: {
              event: "onBackgroundTap",
              target: attributes.onBackgroundTap,
            },
          })
        );
      };
    } else {
      this.htmlElement.onclick = null;
    }
  }
}
