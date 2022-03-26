import { MPEnv, PlatformType } from "../../env";
import { ComponentView } from "../component_view";
import { setDOMAttribute, setDOMStyle } from "../dom_utils";
declare var lazyload: any;

export class Image extends ComponentView {
  elementType() {
    return "img";
  }

  updateLayout() {
    if ((!this.attributes?.width || !this.attributes?.height) && (!this.constraints?.w || !this.constraints?.h)) {
      setDOMStyle(this.htmlElement, {
        position: this.additionalConstraints?.position ?? "absolute",
        left: "0px",
        top: "0px",
        width: "100%",
        height: "100%",
      });
    } else {
      super.updateLayout();
    }
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
    if (attributes.fit && __MP_MINI_PROGRAM__) {
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
      if (attributes.lazyLoad) {
        if (__MP_TARGET_BROWSER__) {
          this.htmlElement.classList.add("lazyload");
          setDOMAttribute(this.htmlElement, "data-src", attributes.src);
          lazyload([this.htmlElement]);
        } else if (__MP_MINI_PROGRAM__) {
          setDOMAttribute(this.htmlElement, "lazyLoad", "true");
          setDOMAttribute(this.htmlElement, "src", attributes.src);
        } else {
          setDOMAttribute(this.htmlElement, "src", attributes.src);
        }
      } else {
        setDOMAttribute(this.htmlElement, "src", attributes.src);
      }
    } else if (attributes.base64) {
      setDOMAttribute(
        this.htmlElement,
        "src",
        `data:image/${attributes.imageType ?? "png"};base64,${attributes.base64}`
      );
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
        if (__MP_MINI_PROGRAM__) {
          assetUrl = "/" + assetUrl;
        }
        setDOMAttribute(this.htmlElement, "src", assetUrl);
      }
    }
    this.updateLayout();
  }
}
