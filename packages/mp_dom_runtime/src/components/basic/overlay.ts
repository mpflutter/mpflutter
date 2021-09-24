import { MPEnv, PlatformType } from "../../env";
import { ComponentView } from "../component_view";
import { setDOMStyle } from "../dom_utils";

export class Overlay extends ComponentView {
  bgElement = this.document.createElement(
    MPEnv.platformType == PlatformType.wxMiniProgram || MPEnv.platformType == PlatformType.swanMiniProgram
      ? "catchmove"
      : "div"
  );
  fgElement = this.document.createElement("div");

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
    });
    setDOMStyle(this.bgElement, {
      position: "absolute",
      zIndex: "10000",
      left: "0px",
      top: "0px",
      right: "0px",
      bottom: "0px",
    });
    setDOMStyle(this.fgElement, {
      position: "absolute",
      zIndex: "10001",
      left: "0px",
      top: "0px",
      right: "0px",
      bottom: "0px",
    });
    this.htmlElement.appendChild(this.bgElement);
    this.htmlElement.appendChild(this.fgElement);
  }

  elementType() {
    return "div";
  }

  setAttributes(attributes: any) {
    super.setAttributes(attributes);
    if (MPEnv.platformType == PlatformType.wxMiniProgram || MPEnv.platformType == PlatformType.swanMiniProgram) {
    } else {
      this.bgElement.addEventListener("touchmove", (e) => {
        e.preventDefault();
      });
    }
    if (attributes.onBackgroundTap) {
      this.fgElement.onclick = () => {
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

  addSubview(view: ComponentView) {
    if (view.superview) {
      view.removeFromSuperview();
    }
    this.subviews.push(view);
    view.superview = this;
    this.fgElement.appendChild(view.htmlElement);
    view.didMoveToWindow();
  }
}
