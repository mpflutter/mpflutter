import { ComponentView } from "../component_view";

export class ClipOval extends ComponentView {
  setAttributes(attributes: any) {
    super.setAttributes(attributes);
  }

  render(canvasContext: CanvasRenderingContext2D): void {
    if (this.constraints) {
      canvasContext.save();
      canvasContext.beginPath();
      this.renderTranslate(canvasContext);
      (canvasContext as any).roundRect(
        0,
        0,
        this.constraints.w,
        this.constraints.h,
        Math.min(this.constraints.w, this.constraints.h) / 2.0
      );
      canvasContext.clip();
      this.renderSubviews(canvasContext);
      canvasContext.restore();
    }
  }
}
