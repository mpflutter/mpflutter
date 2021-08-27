import { ComponentView } from "../component_view";
import { setDOMStyle } from "../dom_utils";

export class SliverPersistentHeader extends ComponentView {
  pinned = true;
  y: number = 0;
  h: number = 0;

  setAttributes(attributes: any) {
    this.attributes = attributes;
    this.pinned = attributes.pinned;
    this.updateLayout();
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
      top: this.h + "px",
      marginTop: y + "px",
      width: this.additionalConstraints?.width ?? w + "px",
      height: this.additionalConstraints?.height ?? h + "px",
      zIndex: "99",
    });
  }
}
