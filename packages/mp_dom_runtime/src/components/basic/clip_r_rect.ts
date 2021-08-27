import { AncestorView, ComponentView } from "../component_view";
import { setDOMStyle } from "../dom_utils";
import { cssBorderRadius } from "../utils";

export class ClipRRect extends ComponentView {
  setAttributes(attributes: any) {
    super.setAttributes(attributes);
    const borderRadius = attributes.borderRadius
      ? cssBorderRadius(attributes.borderRadius)
      : {};
    if (borderRadius.borderRadius) {
      setDOMStyle(this.htmlElement, {
        borderRadius: borderRadius.borderRadius ?? "unset",
        overflow: "hidden",
      });
    } else {
      setDOMStyle(this.htmlElement, {
        borderTopLeftRadius: borderRadius.borderTopLeftRadius ?? "unset",
        borderTopRightRadius: borderRadius.borderTopRightRadius ?? "unset",
        borderBottomLeftRadius: borderRadius.borderBottomLeftRadius ?? "unset",
        borderBottomRightRadius:
          borderRadius.borderBottomRightRadius ?? "unset",
        overflow: "hidden",
      });
    }
  }
}

export class ClipRRectAncestor extends AncestorView {
  setAttributes(attributes: any) {
    super.setAttributes(attributes);
    if (!this.target.ancestorStyle.opacity) {
      this.target.ancestorStyle.opacity = 1.0;
    }
    const borderRadius = attributes.borderRadius
      ? cssBorderRadius(attributes.borderRadius)
      : {};
    if (borderRadius.borderRadius) {
      this.target.ancestorStyle.borderRadius =
        borderRadius.borderRadius ?? "unset";
      this.target.ancestorStyle.overflow = "hidden";
    } else {
      this.target.ancestorStyle.borderTopLeftRadius =
        borderRadius.borderTopLeftRadius ?? "unset";
      this.target.ancestorStyle.borderTopRightRadius =
        borderRadius.borderTopRightRadius ?? "unset";
      this.target.ancestorStyle.borderBottomLeftRadius =
        borderRadius.borderBottomLeftRadius ?? "unset";
      this.target.ancestorStyle.borderBottomRightRadius =
        borderRadius.borderBottomRightRadius ?? "unset";
      this.target.ancestorStyle.overflow = "hidden";
    }
  }
}
