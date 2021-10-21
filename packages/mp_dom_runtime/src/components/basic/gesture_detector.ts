import { MPEnv, PlatformType } from "../../env";
import { ComponentView } from "../component_view";
import { setDOMAttribute, setDOMStyle } from "../dom_utils";

export class GestureDetector extends ComponentView {
  classname = "GestureDetector";
  hoverOpacity = false;
  didSetOnClicked = false;
  didSetOnLongPressOrPan = false;
  longPressTimer: any;
  longPressing = false;
  touchStartPosition?: { x: number; y: number };

  constructor(readonly document: Document) {
    super(document);
    (this.htmlElement as any).isGestureDetector = true;
    this.setupHoverOpacity();
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
    if (attributes.onTap) {
      if (!this.didSetOnClicked) {
        this.didSetOnClicked = true;
        this.htmlElement.addEventListener("click", (e) => {
          this.engine.sendMessage(
            JSON.stringify({
              type: "gesture_detector",
              message: {
                event: "onTap",
                target: attributes.onTap,
              },
            })
          );
          if (e) e.stopPropagation?.();
        });
      }
    }
    if (
      attributes.onLongPress ||
      attributes.onLongPressStart ||
      attributes.onLongPressMoveUpdate ||
      attributes.onLongPressEnd ||
      attributes.onPanStart ||
      attributes.onPanUpdate ||
      attributes.onPanEnd
    ) {
      if (!this.didSetOnLongPressOrPan) {
        this.didSetOnLongPressOrPan = true;
        this.setupLongPressOrPanCatcher();
        if (MPEnv.platformType === PlatformType.wxMiniProgram || MPEnv.platformType === PlatformType.swanMiniProgram) {
          (this.htmlElement as any).setTag("touchmove");
        }
      }
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

  setupHoverOpacity() {
    if (MPEnv.platformType === PlatformType.browser && __MP_TARGET_BROWSER__) {
      this.htmlElement.addEventListener(
        "touchstart",
        (e: TouchEvent) => {
          const targetElement = this.findGestureDetectorElement(e.composedPath() as any);
          if (!GestureDetector.activeTouchElement && targetElement.hoverOpacity) {
            GestureDetector.activeTouchElement = targetElement;
            targetElement.classList.add("hoverOpacity");
          }
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

  setupLongPressOrPanCatcher() {
    this.htmlElement.addEventListener(
      "touchstart",
      (e: TouchEvent) => {
        this._onTouchStart(e);
      },
      true
    );
    this.htmlElement.addEventListener(
      "touchmove",
      (e) => {
        this._onTouchMove(e);
      },
      true
    );
    this.htmlElement.addEventListener(
      "touchend",
      (e) => {
        this._onTouchEnd(e);
      },
      true
    );
    this.htmlElement.addEventListener(
      "touchcancel",
      () => {
        if (this.longPressTimer) {
          clearTimeout(this.longPressTimer);
          this.longPressTimer = undefined;
        }
        this.longPressing = false;
      },
      true
    );
  }

  _onTouchStart(e: TouchEvent) {
    let isPan = this.attributes.onPanStart || this.attributes.onPanUpdate || this.attributes.onPanEnd;
    if (
      this.attributes.onLongPress ||
      this.attributes.onLongPressStart ||
      this.attributes.onLongPressEnd ||
      this.attributes.onLongPressMoveUpdate ||
      isPan
    ) {
      this.touchStartPosition = { x: e.touches[0].clientX, y: e.touches[0].clientY };
      this.longPressTimer = setTimeout(
        () => {
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
            if (this.attributes.onLongPressStart || this.attributes.onPanStart) {
              this.engine.sendMessage(
                JSON.stringify({
                  type: "gesture_detector",
                  message: {
                    event: this.attributes.onPanStart ? "onPanStart" : "onLongPressStart",
                    target: this.attributes.onPanStart ? this.attributes.onPanStart : this.attributes.onLongPressStart,
                    globalX: e.touches[0].clientX,
                    globalY: e.touches[0].clientY,
                  },
                })
              );
            }
            this.longPressTimer = undefined;
          }
        },
        isPan ? 0 : 300
      );
    }
  }

  _onTouchMove(e: TouchEvent) {
    if (this.longPressing && (this.attributes.onLongPressMoveUpdate || this.attributes.onPanUpdate)) {
      this.engine.sendMessage(
        JSON.stringify({
          type: "gesture_detector",
          message: {
            event: this.attributes.onPanUpdate ? "onPanUpdate" : "onLongPressMoveUpdate",
            target: this.attributes.onPanUpdate ? this.attributes.onPanUpdate : this.attributes.onLongPressMoveUpdate,
            globalX: e.touches[0].clientX,
            globalY: e.touches[0].clientY,
          },
        })
      );
    } else if (this.longPressTimer && this.touchStartPosition) {
      const touchMovePosition = { x: e.touches[0].clientX, y: e.touches[0].clientY };
      const deltaX = Math.abs(touchMovePosition.x - this.touchStartPosition.x);
      const deltaY = Math.abs(touchMovePosition.y - this.touchStartPosition.y);
      if (deltaX > 8 || deltaY > 8) {
        clearTimeout(this.longPressTimer);
        this.longPressTimer = undefined;
      }
    }
  }

  _onTouchEnd(e: TouchEvent) {
    if (this.longPressing && (this.attributes.onLongPressEnd || this.attributes.onPanEnd)) {
      this.engine.sendMessage(
        JSON.stringify({
          type: "gesture_detector",
          message: {
            event: this.attributes.onPanEnd ? "onPanEnd" : "onLongPressEnd",
            target: this.attributes.onPanEnd ? this.attributes.onPanEnd : this.attributes.onLongPressEnd,
          },
        })
      );
    } else if (this.longPressTimer) {
      clearTimeout(this.longPressTimer);
      this.longPressTimer = undefined;
    }
    this.longPressing = false;
  }
}
