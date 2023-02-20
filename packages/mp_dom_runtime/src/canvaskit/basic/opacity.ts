import { ComponentView } from "../component_view";

export class Opacity extends ComponentView {
  opacity: number = 1.0;

  setAttributes(attributes: any) {
    super.setAttributes(attributes);
    this.opacity = attributes.opacity;
  }

  render(canvasContext: CanvasRenderingContext2D): void {
    canvasContext.save();
    canvasContext.globalAlpha *= this.opacity;
    this.renderTranslate(canvasContext);
    this.renderSubviews(canvasContext);
    canvasContext.restore();
  }
}
