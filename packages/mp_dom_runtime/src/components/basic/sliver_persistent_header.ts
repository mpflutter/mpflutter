import { MPEnv, PlatformType } from "../../env";
import { ComponentView } from "../component_view";
import { setDOMAttribute, setDOMStyle } from "../dom_utils";

export class SliverPersistentHeader extends ComponentView {
  pinned = true;
  lazying = false;
  observingScroller = false;
  lazyOffset: number = 0;
  y: number = 0;
  h: number = 0;

  setAttributes(attributes: any) {
    this.attributes = attributes;
    this.pinned = attributes.pinned;
    this.lazying = attributes.lazying;
    this.lazyOffset = attributes.lazyOffset;
    this.updateLayout();
    if (this.lazying && !this.observingScroller) {
      this.observeScroller();
      this.updateLazyState(0);
    }
  }

  observeScroller() {
    if (this.lazying && !this.observingScroller) {
      this.observingScroller = true;
      if (__MP_TARGET_BROWSER__) {
        setTimeout(() => {
          if (this.superview) {
            var eventListener: any;
            eventListener = (e: any) => {
              if (!this.htmlElement.isConnected) {
                this.observingScroller = false;
                window.removeEventListener("scroll", eventListener);
              }
              this.updateLazyState(window.scrollY);
            };
            window.addEventListener("scroll", eventListener);
          }
        }, 32);
      } else if (__MP_MINI_PROGRAM__) {
        var eventListener: any;
        eventListener = (e: any) => {
          this.updateLazyState((this.document as any).window.scrollY);
        };
        (this.document as any).window.addEventListener("scroll", eventListener);
      }
    }
  }

  updateLazyState(currentScrollY: number) {
    if (this.lazying) {
      setDOMStyle(this.htmlElement, {
        opacity: currentScrollY > this.lazyOffset ? "1.0" : "0.0",
      });
    }
  }

  updateLayout() {
    if (!this.constraints) return;
    let x: number = this.constraints.x;
    let y: number = this.y;
    let w: number = this.constraints.w;
    let h: number = this.constraints.h;
    this.ancestors.forEach((it) => {
      if (it.constraints) {
        x += it.constraints.x;
        y += it.constraints.y;
      }
    });
    setDOMStyle(this.htmlElement, {
      position: "sticky",
      left: this.additionalConstraints?.left ?? x + "px",
      top: this.pinned ? this.h + "px" : "unset",
      marginTop: this.pinned ? y + "px" : "unset",
      width: this.additionalConstraints?.width ?? w + "px",
      height: this.additionalConstraints?.height ?? h + "px",
      zIndex: "99",
    });
  }
}
