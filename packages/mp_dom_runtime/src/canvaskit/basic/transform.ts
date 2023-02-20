import { ComponentView } from "../component_view";

export class Transform extends ComponentView {
  transformParts: number[] = [1, 0, 0, 1, 0, 0];

  setAttributes(attributes: any) {
    super.setAttributes(attributes);
    if (attributes.transform) {
      const values = attributes.transform.replace("matrix(", "").replace(")", "");
      this.transformParts = values.split(",").map((it: string) => parseFloat(it));
      console.log(this.transformParts);
    }
  }

  render(canvasContext: CanvasRenderingContext2D): void {
    canvasContext.save();
    this.renderTranslate(canvasContext);
    canvasContext.transform(
      this.transformParts[0],
      this.transformParts[1],
      this.transformParts[2],
      this.transformParts[3],
      this.transformParts[4],
      this.transformParts[5]
    );
    this.renderSubviews(canvasContext);
    canvasContext.restore();
  }
}
