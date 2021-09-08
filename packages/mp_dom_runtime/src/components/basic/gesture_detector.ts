import { MPEnv, PlatformType } from "../../env";
import { ComponentView } from "../component_view";
import { setDOMAttribute, setDOMStyle } from "../dom_utils";

export class GestureDetector extends ComponentView {
  hoverOpacity = false;
  didSetOnclicked = false;

  constructor(readonly document: Document) {
    super(document);
    (this.htmlElement as any).isGestureDetector = true;
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
    if (!this.didSetOnclicked) {
      this.didSetOnclicked = true;
      this.htmlElement.onclick = (e) => {
        this.engine.sendMessage(
          JSON.stringify({
            type: "gesture_detector",
            message: {
              event: "onTap",
              target: attributes.onTap,
            },
          })
        );
        if (e) e.stopPropagation();
      };
    }
    this.hoverOpacity = attributes.hoverOpacity;
    (this.htmlElement as any).hoverOpacity = this.hoverOpacity;
    setDOMAttribute(this.htmlElement, "hoverOpacity", attributes.hoverOpacity);
  }

  static activeTouchElement?: HTMLElement;

  findGestureDetectorElement(elementList: HTMLElement[]) {
    for (let index = 0; index < elementList.length; index++) {
      const element = elementList[index] as any;
      if (element.isGestureDetector) {
        return element;
      }
    }
    return undefined;
  }

  setupGestureCatcher() {
    if (MPEnv.platformType === PlatformType.browser) {
      this.htmlElement.addEventListener(
        "touchstart",
        (e: TouchEvent) => {
          if (GestureDetector.activeTouchElement) return;
          const targetElement = this.findGestureDetectorElement(
            e.composedPath() as any
          );
          if (targetElement.hoverOpacity) {
            GestureDetector.activeTouchElement = targetElement;
            targetElement.classList.add("hoverOpacity");
          }
        },
        true
      );
      this.htmlElement.addEventListener(
        "touchmove",
        () => {
          GestureDetector.activeTouchElement?.classList.remove("hoverOpacity");
          GestureDetector.activeTouchElement = undefined;
        },
        true
      );
      this.htmlElement.addEventListener(
        "touchend",
        () => {
          GestureDetector.activeTouchElement?.classList.remove("hoverOpacity");
          GestureDetector.activeTouchElement = undefined;
        },
        true
      );
      this.htmlElement.addEventListener(
        "touchcancel",
        () => {
          GestureDetector.activeTouchElement?.classList.remove("hoverOpacity");
          GestureDetector.activeTouchElement = undefined;
        },
        true
      );
    }
  }
}
