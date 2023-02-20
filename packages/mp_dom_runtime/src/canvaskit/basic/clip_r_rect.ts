import { cssBorderRadius } from "../../components/utils";
import { ComponentView } from "../component_view";

export class ClipRRect extends ComponentView {
  borderRadius: any;

  setAttributes(attributes: any) {
    super.setAttributes(attributes);
    this.borderRadius = attributes.borderRadius ? cssBorderRadius(attributes.borderRadius) : {};
  }

  render(canvasContext: CanvasRenderingContext2D): void {
    // todo
  }
}
