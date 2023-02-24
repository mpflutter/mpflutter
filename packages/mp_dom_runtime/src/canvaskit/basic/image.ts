import { CanvasApp } from "../../canvas_app";
import { ComponentView } from "../component_view";

export class Image extends ComponentView {
  renderElement: any;
  src: string | undefined;

  constructor(readonly initialAttributes?: any) {
    super(initialAttributes);
    this.renderElement = document.createElement("img");
  }

  setAttributes(attributes: any) {
    super.setAttributes(attributes);
    if (this.src !== attributes.src) {
      this.src = attributes.src;
      this.renderElement.src = this.src;
      this.renderElement.onload = () => {
        (this.engine.app as CanvasApp).currentPage?.setNeedsRender();
      };
    }
  }

  render(canvasContext: CanvasRenderingContext2D): void {
    if (this.constraints) {
      canvasContext.save();
      this.renderTranslate(canvasContext);
      canvasContext.drawImage(this.renderElement, 0, 0, this.constraints.w, this.constraints.h);
      canvasContext.restore();
    }
  }
}
