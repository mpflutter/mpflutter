import { MPEnv, PlatformType } from "../../env";
import { ComponentView } from "../component_view";
import { setDOMAttribute, setDOMStyle } from "../dom_utils";

export class GestureDetector extends ComponentView {
  classname = "GestureDetector";
  didSetOnClicked = false;
  didSetOnLongPressOrPan = false;
  longPressTimer: any;
  longPressing = false;
  targetOriginInPage?: { x: number; y: number };
  touchStartPosition?: { x: number; y: number };
  hoverStartPosition?: { x: number; y: number };

  constructor(readonly document: Document) {
    super(document);
    (this.htmlElement as any).isGestureDetector = true;
    this.setupCursor();
  }

  setupCursor() {
    if (MPEnv.platformPC()) {
      this.htmlElement.style.cursor = "pointer";
    }
  }

  elementType() {
    if (__MP_TARGET_WEAPP__) {
      return "wx-catch";
    }
    return "div";
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
          e.stopPropagation();
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
        // if (__MP_TARGET_WEAPP__ || __MP_TARGET_SWANAPP__) {
        //   (this.htmlElement as any).setTag("touchmove");
        // }
      }
    }
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
      (e) => {
        if (this.longPressTimer) {
          clearTimeout(this.longPressTimer);
          this.longPressTimer = undefined;
        }
        this.longPressing = false;
      },
      true
    );
  }

  async _onTouchStart(e: TouchEvent) {
    if (__MP_MINI_PROGRAM__ && (e.target as any)?.tagName === 'CANVAS') return;
    const getBoundingClientRect = __MP_MINI_PROGRAM__ ? await this.htmlElement.getBoundingClientRect() : this.htmlElement.getBoundingClientRect();
    this.targetOriginInPage = { x: getBoundingClientRect.left, y: getBoundingClientRect.top };
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
                    localX: e.touches[0].clientX - this.targetOriginInPage!.x,
                    localY: e.touches[0].clientY - this.targetOriginInPage!.y,
                  },
                })
              );
            }
            this.longPressTimer = undefined;
          }
        },
        isPan ? 0 : 300
      );
      if (isPan) {
        e.preventDefault();
      }
    }
  }

  _onTouchMove(e: TouchEvent) {
    if (__MP_MINI_PROGRAM__ && (e.target as any)?.tagName === 'CANVAS') return;
    if (this.longPressing && (this.attributes.onLongPressMoveUpdate || this.attributes.onPanUpdate)) {
      this.engine.sendMessage(
        JSON.stringify({
          type: "gesture_detector",
          message: {
            event: this.attributes.onPanUpdate ? "onPanUpdate" : "onLongPressMoveUpdate",
            target: this.attributes.onPanUpdate ? this.attributes.onPanUpdate : this.attributes.onLongPressMoveUpdate,
            globalX: e.touches[0].clientX,
            globalY: e.touches[0].clientY,
            localX: e.touches[0].clientX - this.targetOriginInPage!.x,
            localY: e.touches[0].clientY - this.targetOriginInPage!.y,
          },
        })
      );
      e.preventDefault();
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
    if (__MP_MINI_PROGRAM__ && (e.target as any)?.tagName === 'CANVAS') return;
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
      e.preventDefault();
    } else if (this.longPressTimer) {
      clearTimeout(this.longPressTimer);
      this.longPressTimer = undefined;
    }
    this.longPressing = false;
  }
}
