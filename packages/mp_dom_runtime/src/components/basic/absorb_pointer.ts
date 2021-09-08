import { MPEnv, PlatformType } from "../../env";
import { ComponentView } from "../component_view";

export class AbsorbPointer extends ComponentView {
  elementType() {
    return "div";
  }

  setAttributes(attributes: any) {
    super.setAttributes(attributes);
    if (MPEnv.platformType === PlatformType.browser) {
      this.htmlElement.onclick = (e) => {
        if (e) e.stopPropagation();
      };
    } else {
      this.htmlElement.onclick = (e) => {};
    }
  }
}
