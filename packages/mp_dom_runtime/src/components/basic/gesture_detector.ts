import { MPEnv, PlatformType } from "../../env";
import { ComponentView } from "../component_view";
import { setDOMAttribute, setDOMStyle } from "../dom_utils";

export class GestureDetector extends ComponentView {
  classname = "GestureDetector";
  hoverOpacity = false;
  didSetOnClicked = false;
  didSetOnLongPress = false;
  longPressTimer: any;
  longPressing = false;

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
    if (MPEnv.platformType === PlatformType.browser && __MP_TARGET_BROWSER__) {
      this.htmlElement.addEventListener(
        "touchstart",
        (e: TouchEvent) => {
          const targetElement = this.findGestureDetectorElement(e.composedPath() as any);
          if (!GestureDetector.activeTouchElement && targetElement.hoverOpacity) {
            GestureDetector.activeTouchElement = targetElement;
            targetElement.classList.add("hoverOpacity");
          }
          this._onTouchStart(e);
        },
        true
      );
      this.htmlElement.addEventListener(
        "touchmove",
        (e) => {
          GestureDetector.activeTouchElement?.classList.remove("hoverOpacity");
          GestureDetector.activeTouchElement = undefined;
          if (this.longPressTimer) {
            clearTimeout(this.longPressTimer);
            this.longPressTimer = undefined;
          }
          this._onTouchMove(e);
        },
        true
      );
      this.htmlElement.addEventListener(
        "touchend",
        (e) => {
          GestureDetector.activeTouchElement?.classList.remove("hoverOpacity");
          GestureDetector.activeTouchElement = undefined;
          if (this.longPressTimer) {
            clearTimeout(this.longPressTimer);
            this.longPressTimer = undefined;
          }
          this._onTouchEnd(e);
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
          this.longPressing = false;
        },
        true
      );
    } else if (MPEnv.platformType === PlatformType.wxMiniProgram && __MP_TARGET_WEAPP__) {
      this.htmlElement.ontouchstart = (e) => {
        this._onTouchStart(e);
      };
      this.htmlElement.ontouchmove = (e) => {
        this._onTouchMove(e);
      };
      this.htmlElement.ontouchend = (e) => {
        this._onTouchEnd(e);
      };
      this.htmlElement.ontouchcancel = (e) => {
        this.longPressing = false;
      };
    }
  }

  _onTouchStart(e: TouchEvent) {
    if (
      this.attributes.onLongPress ||
      this.attributes.onLongPressStart ||
      this.attributes.onLongPressEnd ||
      this.attributes.onLongPressMoveUpdate
    ) {
      this.longPressTimer = setTimeout(() => {
        if (this.longPressTimer) {
          this.longPressing = true;
          if (this.attributes.onLongPress) {
            this.engine.sendMessage(
              JSON.stringify({
                type: "gesture_detector",
                message: {
                  event: "onLongPress",
                  target: this.attributes.onLongPress,
                },
              })
            );
          }
          if (this.attributes.onLongPressStart) {
            this.engine.sendMessage(
              JSON.stringify({
                type: "gesture_detector",
                message: {
                  event: "onLongPressStart",
                  target: this.attributes.onLongPressStart,
                  globalX: e.touches[0].clientX,
                  globalY: e.touches[0].clientY,
                },
              })
            );
          }
          this.longPressTimer = undefined;
        }
      }, 300);
    }
  }

  _onTouchMove(e: TouchEvent) {
    if (this.longPressing && this.attributes.onLongPressMoveUpdate) {
      this.engine.sendMessage(
        JSON.stringify({
          type: "gesture_detector",
          message: {
            event: "onLongPressMoveUpdate",
            target: this.attributes.onLongPressMoveUpdate,
            globalX: e.touches[0].clientX,
            globalY: e.touches[0].clientY,
          },
        })
      );
    }
  }

  _onTouchEnd(e: TouchEvent) {
    if (this.longPressing && this.attributes.onLongPressEnd) {
      this.engine.sendMessage(
        JSON.stringify({
          type: "gesture_detector",
          message: {
            event: "onLongPressEnd",
            target: this.attributes.onLongPressEnd,
          },
        })
      );
    }
    this.longPressing = false;
  }
}
