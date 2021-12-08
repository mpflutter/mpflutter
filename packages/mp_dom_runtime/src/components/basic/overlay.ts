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
    const isWeapp = __MP_TARGET_WEAPP__ && MPEnv.platformScope.canIUse("page-container") === true;
    if (isWeapp) {
      const sdkVersion = MPEnv.platformScope.getSystemInfoSync().SDKVersion;
      const versionComponents = sdkVersion.split(".");
      if (parseInt(versionComponents[0]) >= 2 && parseInt(versionComponents[1]) >= 19) {
        return true;
      }
    }
    return false;
  }

  elementType() {
    if (this.supportPageContainer()) {
      return "wx-page-container";
    }
    return "div";
  }

  removeFromSuperview() {
    if (this.supportPageContainer()) {
      setDOMAttribute(this.htmlElement, "show", false);
      if (!this.superview) return;
      const index = this.superview.subviews.indexOf(this);
      if (index >= 0) {
        this.superview.subviews[index].htmlElement.remove();
        this.superview?.subviews.splice(index, 1);
      }
      setTimeout(() => {
        this.htmlElement.remove();
      }, 300);
      return;
    }
    super.removeFromSuperview();
    this.htmlElement.remove();
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
