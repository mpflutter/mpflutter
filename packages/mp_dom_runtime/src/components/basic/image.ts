import { MPEnv, PlatformType } from "../../env";
import { ComponentView } from "../component_view";
import { setDOMAttribute, setDOMStyle } from "../dom_utils";

export class Image extends ComponentView {
  elementType() {
    return "img";
  }

  setAttributes(attributes: any) {
    super.setAttributes(attributes);
    setDOMStyle(this.htmlElement, {
      objectFit: (() => {
        if (!attributes.fit) return "cover";
        switch (attributes.fit) {
          case "BoxFit.fill":
            return "fill";
          case "BoxFit.contain":
            return "contain";
          case "BoxFit.cover":
            return "cover";
          case "BoxFit.fitWidth":
            return "scale-down";
          case "BoxFit.fitHeight":
            return "scale-down";
          case "BoxFit.none":
            return "none";
          default:
            return "contain";
        }
      })(),
    });
    if (attributes.fit && MPEnv.platformType === PlatformType.wxMiniProgram) {
      setDOMAttribute(
        this.htmlElement,
        "mode",
        (() => {
          if (!attributes.fit) return "cover";
          switch (attributes.fit) {
            case "BoxFit.fill":
              return "scaleToFill";
            case "BoxFit.contain":
              return "aspectFit";
            case "BoxFit.cover":
              return "aspectFill";
            case "BoxFit.fitWidth":
              return "widthFix";
            case "BoxFit.fitHeight":
              return "heightFix";
            default:
              return "aspectFit";
          }
        })()
      );
    }
    if (attributes.src) {
      setDOMAttribute(this.htmlElement, "src", attributes.src);
    } else if (attributes.assetName) {
      if (this.engine.debugger) {
        const assetUrl = (() => {
          if (attributes.assetPkg) {
            return `http://${this.engine.debugger.serverAddr}/assets/packages/${attributes.assetPkg}/${attributes.assetName}`;
          } else {
            return `http://${this.engine.debugger.serverAddr}/assets/${attributes.assetName}`;
          }
        })();
        setDOMAttribute(this.htmlElement, "src", assetUrl);
      } else {
        let assetUrl = (() => {
          if (attributes.assetPkg) {
            return `assets/packages/${attributes.assetPkg}/${attributes.assetName}`;
          } else {
            return `assets/${attributes.assetName}`;
          }
        })();
        if (MPEnv.platformType === PlatformType.wxMiniProgram) {
          assetUrl = "/" + assetUrl;
        }
        setDOMAttribute(this.htmlElement, "src", assetUrl);
      }
    }
  }
}
