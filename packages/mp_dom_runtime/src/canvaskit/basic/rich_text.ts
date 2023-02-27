declare var wx: any;

import { MPEnv, PlatformType } from "../../env";
import { ComponentView } from "../component_view";

export class RichText extends ComponentView {
  private measuring = false;
  didSetOnClicked = false;
  canMeasureResultCache = false;
  textCache = "";
  textCacheSize = 0;
  measureId: number | undefined;
  maxWidth: number | string | undefined;
  maxHeight: number | string | undefined;

  setConstraints(constraints?: any) {
    if (this.measuring) return;
    if (!constraints) return;
    this.constraints = constraints;
  }

  setAttributes(attributes: any) {
    super.setAttributes(attributes);

  }
}

export class TextSpan extends ComponentView {
  didSetOnClicked = false;

  setChildren(children: any) {
    if (children instanceof Array && children.length > 0) {
      super.setChildren(children);
    }
  }

  setAttributes(attributes: any) {
    super.setAttributes(attributes);
    let style: any = {
      position: "unset",
      display: "inline",
    };
    if (attributes.style) {

    }
    if (attributes.text) {

    }
    if (attributes.onTap_el && attributes.onTap_span && !this.didSetOnClicked) {
      this.didSetOnClicked = true;

    }
  }

  render(canvasContext: CanvasRenderingContext2D): void {
    if (this.constraints) {
      canvasContext.save();
      canvasContext.beginPath();
      this.renderTranslate(canvasContext);

      canvasContext.fillStyle = "#cc0000";
      canvasContext.fillText("Hello World", 10, 50);

      canvasContext.clip();
      this.renderSubviews(canvasContext);
      canvasContext.restore();
    }
  }
}

export class WidgetSpan extends ComponentView {

  setChildren(children: any) {
    super.setChildren(children);

  }

  setAttributes(attributes: any) {
    super.setAttributes(attributes);
  }
}
