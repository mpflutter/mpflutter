import { ComponentView } from "../component_view";
import { setDOMStyle } from "../dom_utils";
import {
  cssBorder,
  cssBorderRadius,
  cssColor,
  cssGradient,
  cssOffset,
} from "../utils";

export class DecoratedBox extends ComponentView {

  setAttributes(attributes: any) {
    super.setAttributes(attributes);
    let style: any = {};
    if (attributes.color) {
      style.backgroundColor = cssColor(attributes.color);
    } else {
      style.backgroundColor = "transparent";
    }
    if (attributes.image) {
      style.backgroundImage = `url("${(() => {
        if (attributes.image.src) {
          return attributes.image.src;
        } else if (attributes.image.assetName) {
          if (this.engine.debugger) {
            const assetUrl = (() => {
              if (attributes.image.assetPkg) {
                return `http://${this.engine.debugger.serverAddr}/assets/packages/${attributes.image.assetPkg}/${attributes.image.assetName}`;
              } else {
                return `http://${this.engine.debugger.serverAddr}/assets/${attributes.image.assetName}`;
              }
            })();
            return assetUrl;
          } else {
            let assetUrl = (() => {
              if (attributes.image.assetPkg) {
                return `assets/packages/${attributes.image.assetPkg}/${attributes.assetName}`;
              } else {
                return `assets/${attributes.image.assetName}`;
              }
            })();
            return assetUrl;
          }
        }
      })()}")`;
      if (attributes.image.fit === "BoxFit.cover") {
        style.backgroundSize = "cover";
      } else {
        style.backgroundSize = "contain";
      }
      style.backgroundRepeat = "no-repeat";
    }
    if (attributes.decoration?.gradient) {
      if (style.backgroundImage) {
        style.backgroundImage =
          cssGradient(attributes.decoration.gradient) +
          "," +
          style.backgroundImage;
      } else {
        style.background = cssGradient(attributes.decoration.gradient);
      }
    }
    if (attributes.decoration?.boxShadow?.[0]) {
      const shadow = attributes.decoration?.boxShadow?.[0];
      style.boxShadow = `${cssOffset(shadow.offset)?.dx}px ${
        cssOffset(shadow.offset)?.dy
      }px ${shadow.blurRadius}px ${shadow.spreadRadius}px ${cssColor(
        shadow.color
      )}`;
    }
    if (attributes.decoration?.borderRadius) {
      let s = cssBorderRadius(attributes.decoration.borderRadius) as any;
      for (const key in s) {
        (style as any)[key] = s[key];
      }
    }
    if (attributes.decoration?.border) {
      let s = cssBorder(attributes.decoration.border) as any;
      s.boxSizing = "border-box";
      for (const key in s) {
        (style as any)[key] = s[key];
      }
    }
    setDOMStyle(this.htmlElement, style);
  }
}
