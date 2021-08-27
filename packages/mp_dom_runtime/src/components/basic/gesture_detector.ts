import { MPEnv, PlatformType } from "../../env";
import { ComponentView } from "../component_view";
import { setDOMAttribute, setDOMStyle } from "../dom_utils";

export class GestureDetector extends ComponentView {
  hoverOpacity = false;

  constructor(readonly document: Document) {
    super(document);
    this.setupGestureCatcher();
  }

  elementType() {
    return "div";
  }

  setConstraints(constraints: any) {
    if (!constraints) return;
    this.constraints = constraints;
    let x: number = constraints.x;
    let y: number = constraints.y;
    let w: number = constraints.w;
    let h: number = constraints.h;
    if (
      typeof x === "number" &&
      typeof y === "number" &&
      typeof w === "number" &&
      typeof h === "number"
    ) {
      setDOMStyle(this.htmlElement, {
        left: "0px",
        top: "0px",
        width: "0.1px",
        height: "0.1px",
      });
    }
  }

  setAttributes(attributes: any) {
    super.setAttributes(attributes);
    this.htmlElement.onclick = () => {
      this.engine.sendMessage(
        JSON.stringify({
          type: "gesture_detector",
          message: {
            event: "onTap",
            target: attributes.onTap,
          },
        })
      );
    };
    this.hoverOpacity = attributes.hoverOpacity;
    setDOMAttribute(this.htmlElement, "hoverOpacity", attributes.hoverOpacity);
  }

  setupGestureCatcher() {
    if (MPEnv.platformType === PlatformType.browser) {
      this.htmlElement.addEventListener(
        "touchstart",
        () => {
          if (this.hoverOpacity) {
            this.htmlElement.className = "hoverOpacity";
          }
        },
        true
      );
      this.htmlElement.addEventListener(
        "touchmove",
        () => {
          if (this.hoverOpacity) {
            this.htmlElement.className = "";
          }
        },
        true
      );
      this.htmlElement.addEventListener(
        "touchend",
        () => {
          if (this.hoverOpacity) {
            this.htmlElement.className = "";
          }
        },
        true
      );
      this.htmlElement.addEventListener(
        "touchcancel",
        () => {
          if (this.hoverOpacity) {
            this.htmlElement.className = "";
          }
        },
        true
      );
    }
  }
}
