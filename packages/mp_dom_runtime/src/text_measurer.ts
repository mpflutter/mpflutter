import { ComponentFactory } from "./components/component_factory";
import { ComponentView } from "./components/component_view";
import { setDOMStyle } from "./components/dom_utils";
import { Engine } from "./engine";
import { MPEnv, PlatformType } from "./env";
import { Router } from "./router";

export class TextMeasurer {
  static activeTextMeasureDocument: Document;

  static async delay() {
    return new Promise((res) => {
      setTimeout(() => {
        res(null);
      }, 50);
    });
  }

  static async didReceivedDoMeasureData(engine: Engine, data: { [key: string]: any }) {
    if (!this.activeTextMeasureDocument) {
      this.activeTextMeasureDocument = document;
    }
    while (Router.beingPush) {
      await this.delay();
    }
    if (data.items) {
      ComponentFactory.disableCache = true;
      let items = data.items;
      const views = items
        .map((it: any) => {
          return engine.componentFactory.create(it, this.activeTextMeasureDocument);
        })
        .filter((it: any) => it) as ComponentView[];
      ComponentFactory.disableCache = false;
      let isTiny = views.length < 5;
      const rects = await Promise.all(
        views.map(async (it) => {
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
          if (!isTiny && (__MP_TARGET_WEAPP__ || __MP_TARGET_SWANAPP__)) {
            await this.delay();
          }
          const rect = await (it.htmlElement as any).getBoundingClientRect();
          it.htmlElement.remove();
          return {
            measureId: it.attributes.measureId,
            width: Math.ceil(rect?.width ?? 0.0) + 1.0,
            height: Math.ceil(rect?.height ?? 0.0) + 1.0,
          };
        })
      );
      rects.forEach((it) => {
        engine.componentFactory.callbackTextMeasureResult(it.measureId, it);
      });
    }
  }
}
