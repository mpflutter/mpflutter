import { cssColor } from "../../components/utils";
import { ComponentView } from "../component_view";

export class ColoredBox extends ComponentView {

  color?: string

  setAttributes(attributes: any) {
    super.setAttributes(attributes);
    this.color = cssColor(attributes.color);
  }

  render(canvasContext: CanvasRenderingContext2D): void {
    if (this.constraints) {
      canvasContext.fillStyle = this.color ?? "transparnet";
      canvasContext.fillRect(this.constraints.x, this.constraints.y, this.constraints.w, this.constraints.h);
    }
  }
}
