import { MPEnv, PlatformType } from "../../env";
import { ComponentView } from "../component_view";
import { setDOMAttribute, setDOMStyle } from "../dom_utils";

export class GestureDetector extends ComponentView {
  classname = "GestureDetector";
  hoverOpacity = false;
  didSetOnClicked = false;
  didSetOnLongPress = false;
  longPressTimer: any;

  constructor(readonly document: Document) {
    super(document);
    (this.htmlElement as any).isGestureDetector = true;
    this.setupGestureCatcher();
  }

  elementType() {
    return "div";
  }

  setChildren(children: any) {
    super.setChildren(children);
    this.subviews.forEach((it) => {
      it.gestureViewConstraints = {
        x: this.constraints?.x ?? 0.0,
        y: this.constraints?.y ?? 0.0,
      };
      it.updateLayout();
    });
  }

  setAttributes(attributes: any) {
    super.setAttributes(attributes);
    if (!this.didSetOnClicked) {
      this.didSetOnClicked = true;
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
          if (this.attributes.onLongPress) {
            this.longPressTimer = setTimeout(() => {
              if (this.longPressTimer) {
                this.engine.sendMessage(
                  JSON.stringify({
                    type: "gesture_detector",
                    message: {
                      event: "onLongPress",
                      target: this.attributes.onLongPress,
                    },
                  })
                );
                this.longPressTimer = undefined;
              }
            }, 300);
          }
        },
        true
      );
      this.htmlElement.addEventListener(
        "touchmove",
        () => {
          GestureDetector.activeTouchElement?.classList.remove("hoverOpacity");
          GestureDetector.activeTouchElement = undefined;
          if (this.longPressTimer) {
            clearTimeout(this.longPressTimer);
            this.longPressTimer = undefined;
          }
        },
        true
      );
      this.htmlElement.addEventListener(
        "touchend",
        () => {
          GestureDetector.activeTouchElement?.classList.remove("hoverOpacity");
          GestureDetector.activeTouchElement = undefined;
          if (this.longPressTimer) {
            clearTimeout(this.longPressTimer);
            this.longPressTimer = undefined;
          }
        },
        true
      );
      this.htmlElement.addEventListener(
        "touchcancel",
        () => {
          GestureDetector.activeTouchElement?.classList.remove("hoverOpacity");
          GestureDetector.activeTouchElement = undefined;
          if (this.longPressTimer) {
            clearTimeout(this.longPressTimer);
            this.longPressTimer = undefined;
          }
        },
        true
      );
    }
  }
}
