import { MPEnv, PlatformType } from "../../env";
import { ComponentView } from "../component_view";
import { GestureDetector } from "./gesture_detector";

export class AbsorbPointer extends ComponentView {
  didSetListener = false;

  elementType() {
    return "div";
  }

  setAttributes(attributes: any) {
    super.setAttributes(attributes);
    if (!this.didSetListener) {
      this.didSetListener = true;
      if (__MP_TARGET_BROWSER__) {
        this.htmlElement.addEventListener("click", (e) => {
          e.stopPropagation();
        });
        this.htmlElement.addEventListener("touchstart", (e) => {
          GestureDetector.activeTouchElement = undefined;
        });
      } else {
        this.htmlElement.addEventListener("click", (e) => {
          e.stopPropagation();
        });
      }
    }
  }
}
