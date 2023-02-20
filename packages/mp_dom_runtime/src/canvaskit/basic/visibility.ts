import { ComponentView } from "../component_view";

export class Visibility extends ComponentView {
  visible: boolean = true;

  setAttributes(attributes: any) {
    super.setAttributes(attributes);
    this.visible = attributes.visible;
  }

  render(canvasContext: CanvasRenderingContext2D): void {
    if (!this.visible) return;
    canvasContext.save();
    this.renderTranslate(canvasContext);
    this.renderSubviews(canvasContext);
    canvasContext.restore();
  }
}
