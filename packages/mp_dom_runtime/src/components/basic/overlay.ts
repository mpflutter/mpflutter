import { MPEnv, PlatformType } from "../../env";
import { ComponentView } from "../component_view";
import { setDOMAttribute, setDOMStyle } from "../dom_utils";

export class Overlay extends ComponentView {
  didSetListener = false;

  constructor(document: Document, readonly initialAttributes?: any) {
    super(document, initialAttributes);
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

  supportPageContainer() {
    return __MP_TARGET_WEAPP__ && MPEnv.platformScope.canIUse("page-container") === true;
  }

  elementType() {
    if (this.supportPageContainer()) {
      return "wx-page-container";
    }
    return "div";
  }

  setAttributes(attributes: any) {
    super.setAttributes(attributes);
    if (this.supportPageContainer()) {
      setDOMAttribute(this.htmlElement, "show", true);
      setDOMAttribute(this.htmlElement, "position", "center");
      setDOMAttribute(this.htmlElement, "duration", "0");
      setDOMAttribute(
        this.htmlElement,
        "custom-style",
        "position:fixed;z-index:10000;left:0px;top:0px;right:0px;bottom:0px;background-color:transparent;"
      );
      setDOMAttribute(this.htmlElement, "overlay-style", "background-color:transparent;");
    }
    if (attributes.onBackgroundTap && !this.didSetListener) {
      this.didSetListener = true;
      this.htmlElement.addEventListener("click", (e) => {
        if (!attributes.onBackgroundTap) return;
        if (attributes.barrierDismissible === true) {
          setDOMAttribute(this.htmlElement, "show", false);
          this.htmlElement.remove();
        }
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
      if (this.supportPageContainer()) {
        this.htmlElement.addEventListener("afterleave", () => {
          this.engine.sendMessage(
            JSON.stringify({
              type: "overlay",
              message: {
                event: "forceClose",
                target: this.hashCode,
              },
            })
          );
        });
      }
    }
  }
}
