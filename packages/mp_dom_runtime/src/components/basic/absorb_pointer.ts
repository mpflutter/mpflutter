import { MPEnv, PlatformType } from "../../env";
import { ComponentView } from "../component_view";

export class AbsorbPointer extends ComponentView {
  elementType() {
    if (MPEnv.platformType == PlatformType.wxMiniProgram) {
      return "catchclick";
    } else {
      return "div";
    }
  }

  setAttributes(attributes: any) {
    super.setAttributes(attributes);
    this.htmlElement.onclick = (e) => {
      if (e) e.stopPropagation();
    };
  }
}
