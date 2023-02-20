import { ComponentView } from "../component_view";

export class Offstage extends ComponentView {
  offstage: boolean = true;

  setAttributes(attributes: any) {
    super.setAttributes(attributes);
    this.offstage = attributes.offstage;
  }

  render(canvasContext: CanvasRenderingContext2D): void {
    if (this.offstage) {
      return;
    }
    canvasContext.save();
    this.renderTranslate(canvasContext);
    this.renderSubviews(canvasContext);
    canvasContext.restore();
  }
}
