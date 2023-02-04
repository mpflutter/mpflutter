import { Engine } from "../../engine";
import { MPEnv } from "../../env";
import { ComponentView } from "../component_view";
import { setDOMAttribute, setDOMStyle } from "../dom_utils";
import { cssColor, getFontStyleStyle, getFontWeightStyle, getBaselineStyle } from "../utils";

export class MPDrawable {
  constructor(readonly engine: Engine) {}

  static offscreenCanvas: any; // use for weapp.
  decodedDrawables: { [key: string]: HTMLImageElement } = {};

  async decodeDrawable(params: any) {
    if (__MP_MINI_PROGRAM__) {
      if (!MPDrawable.offscreenCanvas) {
        if (MPEnv.platformByteDance()) {
          MPDrawable.offscreenCanvas = await (() => {
            return new Promise((resolver) => {
              try {
                MPEnv.platformScope
                  .createSelectorQuery()
                  .select("#mockOffscreenCanvas")
                  .node()
                  .exec((res: any) => {
                    resolver(res[0].node);
                  });
              } catch (error) {
                resolver(undefined);
              }
            });
          })();
        } else {
          MPDrawable.offscreenCanvas = MPEnv.platformScope.createOffscreenCanvas();
        }
      }
    }
    try {
      if (params.type === "networkImage") {
        const result = await this.decodeNetworkImage(params.url, params.target);
        this.engine.sendMessage(
          JSON.stringify({
            type: "decode_drawable",
            message: {
              event: "onDecode",
              target: params.target,
              width: result.width,
              height: result.height,
            },
          })
        );
      } else if (params.type === "memoryImage") {
        const result = await this.decodeMemoryImage(params.data, params.imageType, params.target);
        this.engine.sendMessage(
          JSON.stringify({
            type: "decode_drawable",
            message: {
              event: "onDecode",
              target: params.target,
              width: result.width,
              height: result.height,
            },
          })
        );
      } else if (params.type === "assetImage") {
        const result = await this.decodeAssetImage(params.assetName, params.assetPkg, params.target);
        this.engine.sendMessage(
          JSON.stringify({
            type: "decode_drawable",
            message: {
              event: "onDecode",
              target: params.target,
              width: result.width,
              height: result.height,
            },
          })
        );
      } else if (params.type === "dispose") {
        delete this.decodedDrawables[params.target];
      } else {
        throw new Error("Unknown drawable type.");
      }
    } catch (error: any) {
      this.engine.sendMessage(
        JSON.stringify({
          type: "decode_drawable",
          message: {
            event: "onError",
            target: params.target,
            error: error?.toString(),
          },
        })
      );
    }
  }

  async decodeNetworkImage(url: string, hashCode: number): Promise<{ width: number; height: number }> {
    return new Promise((res, rej) => {
      if (__MP_MINI_PROGRAM__ && !MPDrawable.offscreenCanvas) {
        MPEnv.platformScope.getImageInfo({
          src: url,
          success: (r: any) => {
            this.decodedDrawables[hashCode] = { width: r.width, height: r.height } as any;
            res({ width: r.width, height: r.height });
          },
          fail: (err: any) => {
            rej("");
          },
        });
        return;
      }
      const img = (() => {
        if (__MP_MINI_PROGRAM__) {
          return MPDrawable.offscreenCanvas.createImage();
        }
        return document.createElement("img");
      })();
      img.onload = () => {
        this.decodedDrawables[hashCode] = img;
        res({ width: img.width, height: img.height });
      };
      img.onerror = function () {
        rej("");
      };
      img.src = url;
    });
  }

  async decodeMemoryImage(
    data: string,
    imageType: string,
    hashCode: number
  ): Promise<{ width: number; height: number }> {
    return new Promise((res, rej) => {
      const img = (() => {
        if (__MP_MINI_PROGRAM__) {
          return MPDrawable.offscreenCanvas.createImage();
        }
        return document.createElement("img");
      })();
      img.onload = () => {
        this.decodedDrawables[hashCode] = img;
        res({ width: img.width, height: img.height });
      };
      img.onerror = function () {
        rej("");
      };
      img.src = `data:image/${imageType ?? "png"};base64,${data}`;
    });
  }

  async decodeAssetImage(
    assetName: string,
    assetPkg: string,
    hashCode: number
  ): Promise<{ width: number; height: number }> {
    return new Promise((res, rej) => {
      const img = (() => {
        if (__MP_MINI_PROGRAM__) {
          return MPDrawable.offscreenCanvas.createImage();
        }
        return document.createElement("img");
      })();
      img.onload = () => {
        this.decodedDrawables[hashCode] = img;
        res({ width: img.width, height: img.height });
      };
      img.onerror = function () {
        rej("");
      };
      if (this.engine.debugger) {
        const assetUrl = (() => {
          if (assetPkg) {
            return `http://${this.engine.debugger.serverAddr}/assets/packages/${assetPkg}/${assetName}`;
          } else {
            return `http://${this.engine.debugger.serverAddr}/assets/${assetName}`;
          }
        })();
        img.src = assetUrl;
      } else {
        let assetUrl = (() => {
          if (assetPkg) {
            return `assets/packages/${assetPkg}/${assetName}`;
          } else {
            return `assets/${assetName}`;
          }
        })();
        if (__MP_MINI_PROGRAM__) {
          assetUrl = "/" + assetUrl;
        }
        img.src = assetUrl;
      }
    });
  }
}

export class CustomPaint extends ComponentView {
  static async didReceivedCustomPaintMessage(params: any, engine: any) {
    if (params.event === "fetchImage") {
      this.fetchImage(params, engine);
    } else if (params.event === "asyncPaint") {
      this.asyncPaint(params, engine);
    }
  }

  static async fetchImage(params: any, engine: any) {
    const view = engine.componentFactory.cachedView[params.target] as CustomPaint;
    if (__MP_TARGET_BROWSER__ && view instanceof CustomPaint) {
      const data = (view.htmlElement as HTMLCanvasElement).toDataURL();
      const base64EncodedData = data.split("base64,")[1];
      engine.sendMessage(
        JSON.stringify({
          type: "custom_paint",
          message: {
            event: "onFetchImageResult",
            seqId: params.seqId,
            data: base64EncodedData,
          },
        })
      );
    } else if (__MP_TARGET_WEAPP__ && view instanceof CustomPaint) {
      const node = await (view.htmlElement as any).$$getNodesRef();
      node
        .fields(
          {
            node: true,
          },
          (fields: any) => {
            const canvas = fields.node;
            const data = canvas.toDataURL();
            const base64EncodedData = data.split("base64,")[1];
            engine.sendMessage(
              JSON.stringify({
                type: "custom_paint",
                message: {
                  event: "onFetchImageResult",
                  seqId: params.seqId,
                  data: base64EncodedData,
                },
              })
            );
          }
        )
        .exec();
    }
  }

  static async asyncPaint(params: any, engine: any) {
    const view = engine.componentFactory.cachedView[params.target] as CustomPaint;
    if (view instanceof CustomPaint) {
      const ctx = await view.createContext();
      if (params.commands) {
        view.drawWithCommands(params.commands, ctx);
      }
    }
  }

  canvasWidth: number = 0;
  canvasHeight: number = 0;
  ctx?: CanvasRenderingContext2D;

  constructor(readonly document: any) {
    super(document);
    if (__MP_MINI_PROGRAM__) {
      this.htmlElement.setAttribute("type", "2d");
    }
  }

  elementType() {
    return "canvas";
  }

  setConstraints(constraints: any) {
    if (!constraints) return;
    let x: number = constraints.x;
    let y: number = constraints.y;
    let w: number = constraints.w;
    let h: number = constraints.h;
    if (typeof x === "number" && typeof y === "number" && typeof w === "number" && typeof h === "number") {
      setDOMStyle(this.htmlElement, {
        left: x + "px",
        top: y + "px",
        width: w + "px",
        height: h + "px",
      });
      if (this.canvasWidth !== w || this.canvasHeight != h) {
        this.canvasWidth = w;
        this.canvasHeight = h;
        if (__MP_TARGET_BROWSER__) {
          setDOMAttribute(this.htmlElement, "width", (this.canvasWidth * window.devicePixelRatio).toString());
          setDOMAttribute(this.htmlElement, "height", (this.canvasHeight * window.devicePixelRatio).toString());
          (this.htmlElement as HTMLCanvasElement)
            .getContext("2d")
            ?.scale(window.devicePixelRatio, window.devicePixelRatio);
        }
      }
    }
  }

  async createContext(): Promise<CanvasRenderingContext2D | null> {
    if (__MP_MINI_PROGRAM__) {
      return new Promise((res) => {
        setTimeout(async () => {
          (await (this.htmlElement as any).$$getNodesRef())
            .fields(
              {
                node: true,
                size: true,
              },
              (fields: any) => {
                const canvas = fields.node;
                const ctx = canvas.getContext("2d");
                const dpr = MPEnv.platformScope.getSystemInfoSync().pixelRatio;
                canvas.width = fields.width * dpr;
                canvas.height = fields.height * dpr;
                ctx.scale(dpr, dpr);
                res(ctx);
              }
            )
            .exec();
        }, 16);
      });
    } else {
      return (this.htmlElement as HTMLCanvasElement).getContext("2d");
    }
  }

  drawWithCommands(commands: any[], ctx: any) {
    ctx.save();
    commands.forEach((cmd) => {
      if (cmd.action === "drawRect") {
        this.drawRect(ctx, cmd);
      } else if (cmd.action === "drawPath") {
        this.drawPath(ctx, cmd);
      } else if (cmd.action === "drawDRRect") {
        this.drawDRRect(ctx, cmd);
      } else if (cmd.action === "clipPath") {
        this.drawPath(ctx, cmd);
      } else if (cmd.action === "drawColor") {
        this.drawColor(ctx, cmd);
      } else if (cmd.action === "drawImage") {
        this.drawImage(ctx, cmd);
      } else if (cmd.action === "drawImageRect") {
        this.drawImageRect(ctx, cmd);
      } else if (cmd.action === "drawText") {
        this.drawText(ctx, cmd);
      } else if (cmd.action === "restore") {
        ctx.restore();
      } else if (cmd.action === "rotate") {
        ctx.rotate(cmd.radians);
      } else if (cmd.action === "save") {
        ctx.save();
      } else if (cmd.action === "scale") {
        ctx.scale(cmd.sx, cmd.sy);
      } else if (cmd.action === "skew") {
        ctx.transform(1.0, cmd.sy, cmd.sx, 1.0, 0.0, 0.0);
      } else if (cmd.action === "transform") {
        ctx.transform(cmd.a, cmd.b, cmd.c, cmd.d, cmd.tx, cmd.ty);
      } else if (cmd.action === "translate") {
        ctx.translate(cmd.dx, cmd.dy);
      }
    });
    ctx.restore();
  }

  async setAttributes(attributes: any) {
    super.setAttributes(attributes);
    const ctx = this.ctx ?? (await this.createContext());
    if (!ctx) return;
    if (!this.ctx) {
      this.ctx = ctx;
    }
    if (attributes.commands) {
      this.drawWithCommands(attributes.commands, ctx);
    }
  }

  drawRect(ctx: CanvasRenderingContext2D, params: any) {
    this.setPaint(ctx, params.paint);
    if (params.paint.style === "PaintingStyle.fill") {
      ctx.fillRect(params.x, params.y, params.width, params.height);
    } else {
      ctx.strokeRect(params.x, params.y, params.width, params.height);
    }
  }

  drawPath(ctx: CanvasRenderingContext2D, params: any) {
    this.setPaint(ctx, params.paint);
    this.drawRealPath(ctx, params.path);
    if (params.action === "clipPath") {
      ctx.clip();
    } else if (params.paint.style === "PaintingStyle.fill") {
      ctx.fill();
    } else {
      ctx.stroke();
    }
  }

  drawDRRect(ctx: CanvasRenderingContext2D, params: any) {
    const offscreenCanvas = document.createElement("canvas");
    offscreenCanvas.width = ctx.canvas.width;
    offscreenCanvas.height = ctx.canvas.height;
    const offscreenContext = offscreenCanvas.getContext("2d")!;
    this.setPaint(offscreenContext, params.paint);
    this.drawRealPath(offscreenContext, params.outer);
    if (params.paint.style === "PaintingStyle.fill") {
      offscreenContext.fill();
    } else {
      offscreenContext.stroke();
    }
    offscreenContext.save();
    offscreenContext.fillStyle = "white";
    offscreenContext.globalCompositeOperation = "xor";
    this.drawRealPath(offscreenContext, params.inner);
    offscreenContext.fill();
    offscreenContext.restore();
    ctx.drawImage(offscreenCanvas, 0, 0);
  }

  drawRealPath(ctx: CanvasRenderingContext2D, path: any) {
    ctx.beginPath();
    (path.commands as any[]).forEach((it) => {
      if (it.action === "moveTo") {
        ctx.moveTo(it.x, it.y);
      } else if (it.action === "lineTo") {
        ctx.lineTo(it.x, it.y);
      } else if (it.action === "quadraticBezierTo") {
        ctx.quadraticCurveTo(it.x1, it.y1, it.x2, it.y2);
      } else if (it.action === "cubicTo") {
        ctx.bezierCurveTo(it.x1, it.y1, it.x2, it.y2, it.x3, it.y3);
      } else if (it.action === "arcTo") {
        ctx.ellipse(
          it.x,
          it.y,
          it.width / 2.0,
          it.height / 2.0,
          0,
          it.startAngle,
          it.startAngle + it.sweepAngle,
          it.sweepAngle < 0.0
        );
      } else if (it.action === "arcToPoint") {
        ctx.arcTo(it.arcControlX, it.arcControlY, it.arcEndX, it.arcEndY, it.radiusX);
      } else if (it.action === "close") {
        ctx.closePath();
      }
    });
  }

  drawColor(ctx: CanvasRenderingContext2D, params: any) {
    if (params.blendMode === "BlendMode.clear") {
      ctx.clearRect(0, 0, ctx.canvas.width, ctx.canvas.height);
    } else {
      ctx.fillStyle = cssColor(params.color);
      ctx.fillRect(0, 0, ctx.canvas.width, ctx.canvas.height);
    }
  }

  drawImage(ctx: CanvasRenderingContext2D, params: any) {
    this.setPaint(ctx, params.paint);
    const drawable = this.engine.drawable.decodedDrawables[params.drawable];
    if (drawable) {
      ctx.drawImage(drawable, params.dx, params.dy);
    }
  }

  drawImageRect(ctx: CanvasRenderingContext2D, params: any) {
    this.setPaint(ctx, params.paint);
    const drawable = this.engine.drawable.decodedDrawables[params.drawable];
    if (drawable) {
      ctx.drawImage(
        drawable,
        params.srcX,
        params.srcY,
        params.srcW,
        params.srcH,
        params.dstX,
        params.dstY,
        params.dstW,
        params.dstH
      );
    }
  }

  drawText(ctx: CanvasRenderingContext2D, params: any) {
    const text = params.text;
    const style = params.style;
    const offset = params.offset;
    this.setTextStyle(ctx, style);
    this.setPaint(ctx, params.paint);
    if (params.paint.style === "PaintingStyle.fill") {
      ctx.fillText(text, offset.x, offset.y);
    } else {
      ctx.strokeText(text, offset.x, offset.y);
    }
  }

  setTextStyle(ctx: CanvasRenderingContext2D, style: any) {
    let font = `${(style.fontSize ?? 14).toString()}px ${style.fontFamily ?? "system-ui"}`;
    let fontWeight = getFontWeightStyle(style);
    if (fontWeight) {
      font = fontWeight + " " + font;
    }
    let fontStyle = getFontStyleStyle(style);
    if (fontStyle) {
      font = fontStyle + " " + font;
    }
    ctx.font = font;
    ctx.textBaseline = getBaselineStyle(style) ?? "middle";
  }

  setPaint(ctx: CanvasRenderingContext2D, paint: any) {
    if (!paint) return;
    ctx.lineWidth = paint.strokeWidth;
    ctx.miterLimit = paint.strokeMiterLimit;
    ctx.lineCap = paint.strokeCap.replace("StrokeCap.", "");
    ctx.lineJoin = paint.strokeJoin.replace("StrokeJoin.", "");
    if (paint.style === "PaintingStyle.fill") {
      if (paint.gradient) {
        ctx.fillStyle = this.createGradient(ctx, paint.gradient);
      } else {
        ctx.fillStyle = cssColor(paint.color);
      }
      ctx.strokeStyle = "transparent";
    } else {
      ctx.fillStyle = "transparent";
      if (paint.gradient) {
        ctx.strokeStyle = this.createGradient(ctx, paint.gradient);
      } else {
        ctx.strokeStyle = cssColor(paint.color);
      }
    }
    ctx.globalAlpha = paint.alpha ?? 1.0;
  }

  createGradient(ctx: CanvasRenderingContext2D, gradient: any): any {
    if (gradient.classname === "LinearGradient") {
      let ctxGradient = ctx.createLinearGradient(gradient.fromX, gradient.fromY, gradient.toX, gradient.toY);
      if (gradient.stops && gradient.stops.length) {
        gradient.colors.forEach((it: string, idx: number) => {
          if (gradient.stops[idx] !== undefined) {
            ctxGradient.addColorStop(gradient.stops[idx], cssColor(it));
          }
        });
      } else {
        let stepLength = 1.0 / (gradient.colors.length - 1.0);
        gradient.colors.forEach((it: string, idx: number) => {
          if (gradient.stops[idx] !== undefined) {
            ctxGradient.addColorStop(idx * stepLength, cssColor(it));
          }
        });
      }
      return ctxGradient;
    }
  }
}
