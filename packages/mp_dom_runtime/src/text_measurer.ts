import { RichText } from "./components/basic/rich_text";
import { ComponentFactory } from "./components/component_factory";
import { ComponentView } from "./components/component_view";
import { setDOMStyle } from "./components/dom_utils";
import { Engine } from "./engine";
import { Router } from "./router";

export class TextMeasurer {
  static activeTextMeasureDocument: Document;
  private static zhMeasureCache: { [key: number]: { width: number; height: number } } = {};

  static async delay(scale: number = 1) {
    return new Promise((res) => {
      setTimeout(() => {
        res(null);
      }, 50 * scale);
    });
  }

  static calcMeasureCache(view: ComponentView): { measureId: number; width: number; height: number } | undefined {
    const text = (view as any).textCache;
    const textSize = (view as any).textCacheSize;
    const calcSize = this.zhMeasureCache[textSize]
      ? {
          measureId: view.attributes.measureId,
          width: Math.ceil(this.zhMeasureCache[textSize].width * text.length) + 1.0,
          height: Math.ceil(this.zhMeasureCache[textSize].height) + 1.0,
        }
      : undefined;
    if (view.constraints) {
      if (calcSize && (calcSize.width < view.constraints.w || view.constraints.w === 0)) {
        return calcSize;
      }
    }
    return undefined;
  }

  static saveMeasureCache(view: ComponentView, rect: { width: number; height: number }) {
    const text = (view as any).textCache;
    const textSize = (view as any).textCacheSize;
    if (view.constraints && (view.constraints.w > rect.width + 44.0 || view.constraints.w === 0)) {
      const oneLetterSize = { width: rect.width / text.length, height: rect.height };
      this.zhMeasureCache[textSize] = oneLetterSize;
    }
  }

  static async didReceivedDoMeasureTextPainter(engine: Engine, data: { [key: string]: any }) {
    if (!this.activeTextMeasureDocument) {
      this.activeTextMeasureDocument = document;
    }
    while (Router.beingPush) {
      await this.delay();
    }
    while (!this.activeTextMeasureDocument) {
      await this.delay();
    }
    const view = new RichText(this.activeTextMeasureDocument, {});
    view.setAttributes({ maxWidth: data.maxWidth });
    view.setSingleTextSpan([data.text]);
    setDOMStyle(view.htmlElement, {
      position: "fixed",
      top: "0px",
      left: "0px",
      opacity: "0",
      width: "unset",
      maxWidth:
        view.attributes?.maxWidth && view.attributes?.maxWidth !== "Infinity"
          ? view.attributes?.maxWidth + "px"
          : "999999px",
      height: "unset",
      maxHeight:
        view.attributes?.maxHeight && view.attributes?.maxHeight !== "Infinity"
          ? view.attributes?.maxHeight + "px"
          : "999999px",
    });
    this.activeTextMeasureDocument.body.appendChild(view.htmlElement);
    if (__MP_MINI_PROGRAM__) {
      await this.delay();
    }
    const rect = await (view.htmlElement as any).getBoundingClientRect();
    view.htmlElement.remove();
    engine.componentFactory.callbackTextPainterMeasureResult(data.seqId, rect);
  }

  static async didReceivedDoMeasureData(engine: Engine, data: { [key: string]: any }) {
    if (!this.activeTextMeasureDocument) {
      this.activeTextMeasureDocument = document;
    }
    while (Router.beingPush) {
      await this.delay();
    }
    while (!this.activeTextMeasureDocument) {
      await this.delay();
    }
    let tryCount = 1;
    while (tryCount < 5) {
      try {
        if (data.items) {
          ComponentFactory.disableCache = true;
          let items = data.items;
          const views = items
            .map((it: any) => {
              return engine.componentFactory.create(it, this.activeTextMeasureDocument);
            })
            .filter((it: any) => it) as ComponentView[];
          ComponentFactory.disableCache = false;
          const viewParts: ComponentView[][] = [];
          for (let index = 0; index < views.length; index += 100) {
            viewParts.push(views.slice(index, index + 100));
          }
          let rects: { measureId: any; width: number; height: number }[] = [];
          for (let index = 0; index < viewParts.length; index++) {
            const views = viewParts[index];
            const viewRects = await Promise.all(
              views.map(async (it) => {
                if ((it as any).canMeasureResultCache) {
                  const cacheResult = this.calcMeasureCache(it);
                  if (cacheResult) return cacheResult;
                }
                setDOMStyle(it.htmlElement, {
                  position: "fixed",
                  top: "0px",
                  left: "0px",
                  opacity: "0",
                  width: "unset",
                  maxWidth:
                    it.attributes?.maxWidth && it.attributes?.maxWidth !== "Infinity"
                      ? it.attributes?.maxWidth + "px"
                      : "999999px",
                  height: "unset",
                  maxHeight:
                    it.attributes?.maxHeight && it.attributes?.maxHeight !== "Infinity"
                      ? it.attributes?.maxHeight + "px"
                      : "999999px",
                });
                this.activeTextMeasureDocument.body.appendChild(it.htmlElement);
                if (__MP_MINI_PROGRAM__) {
                  await this.delay(tryCount);
                }
                const rect = await (it.htmlElement as any).getBoundingClientRect();
                it.htmlElement.remove();
                if ((it as any).canMeasureResultCache) {
                  this.saveMeasureCache(it, rect);
                }
                return {
                  measureId: it.attributes.measureId,
                  width: Math.ceil(rect?.width ?? 0.0) + 2.0,
                  height: Math.ceil(rect?.height ?? 0.0) + 1.0,
                };
              })
            );
            rects.push(...viewRects);
          }
          rects.forEach((it) => {
            engine.componentFactory.callbackTextMeasureResult(it.measureId, it);
          });
          break;
        }
      } catch (error) {
        tryCount++;
      }
    }
  }
}
