import { ComponentView } from "../component_view";

export class ClipOval extends ComponentView {
  setAttributes(attributes: any) {
    super.setAttributes(attributes);
  }
  /**
 * 绘制圆角矩形
 * @param {Object} ctx - canvas组件的绘图上下文
 * @param {Number} x - 矩形的x坐标
 * @param {Number} y - 矩形的y坐标
 * @param {Number} w - 矩形的宽度
 * @param {Number} h - 矩形的高度
 * @param {Number} r - 矩形的圆角半径
 * @param {String} [c = 'transparent'] - 矩形的填充色
 */
  roundRect(ctx: CanvasRenderingContext2D, x: number, y: number, w: number, h: number, r: number, c = 'transparent') {

    if (w < 2 * r) { r = w / 2; }
    if (h < 2 * r) { r = h / 2; }

    ctx.beginPath();
    ctx.fillStyle = c;

    ctx.arc(x + r, y + r, r, Math.PI, Math.PI * 1.5);
    ctx.moveTo(x + r, y);
    ctx.lineTo(x + w - r, y);
    ctx.lineTo(x + w, y + r);

    ctx.arc(x + w - r, y + r, r, Math.PI * 1.5, Math.PI * 2);
    ctx.lineTo(x + w, y + h - r);
    ctx.lineTo(x + w - r, y + h);

    ctx.arc(x + w - r, y + h - r, r, 0, Math.PI * 0.5);
    ctx.lineTo(x + r, y + h);
    ctx.lineTo(x, y + h - r);

    ctx.arc(x + r, y + h - r, r, Math.PI * 0.5, Math.PI);
    ctx.lineTo(x, y + r);
    ctx.lineTo(x + r, y);

    ctx.fill();
    ctx.closePath();

  }

  render(canvasContext: CanvasRenderingContext2D): void {
    if (this.constraints) {
      canvasContext.save();
      canvasContext.beginPath();
      this.renderTranslate(canvasContext);

      this.roundRect(canvasContext, 0, 0, this.constraints.w, this.constraints.h, Math.min(this.constraints.w, this.constraints.h) / 2.0);
      canvasContext.arc(0, 0, this.constraints.w, this.constraints.h, 2 * Math.PI)
      canvasContext.clip();
      this.renderSubviews(canvasContext);
      canvasContext.restore();
    }
  }

}
