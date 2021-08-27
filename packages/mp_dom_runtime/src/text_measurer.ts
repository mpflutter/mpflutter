import { ComponentFactory } from "./components/component_factory";
import { ComponentView } from "./components/component_view";
import { setDOMStyle } from "./components/dom_utils";
import { Engine } from "./engine";
import { MPEnv, PlatformType } from "./env";

export class TextMeasurer {
  static activeTextMeasureDocument: Document;

  static async didReceivedDoMeasureData(
    engine: Engine,
    data: { [key: string]: any }
  ) {
    if (!this.activeTextMeasureDocument) {
      this.activeTextMeasureDocument = document;
    }
    if (data.items) {
      ComponentFactory.disableCache = true;
      let items = data.items;
      const views = items
        .map((it: any) => {
          return engine.componentFactory.create(
            it,
            this.activeTextMeasureDocument
          );
        })
        .filter((it: any) => it) as ComponentView[];
      ComponentFactory.disableCache = false;
      const rects = await Promise.all(
        views.map(async (it) => {
          if (MPEnv.platformType === PlatformType.wxMiniProgram) {
            (it.htmlElement as any).setClass = "tm";
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
              it.attributes?.maxHeight &&
              it.attributes?.maxHeight !== "Infinity"
                ? it.attributes?.maxHeight + "px"
                : "999999px",
          });
          this.activeTextMeasureDocument.body.appendChild(it.htmlElement);
          if (MPEnv.platformType === PlatformType.wxMiniProgram) {
            await (this.activeTextMeasureDocument as any).awaitSetState();
          }
          const rect = await it.htmlElement.getBoundingClientRect();
          it.htmlElement.remove();
          return {
            measureId: it.attributes.measureId,
            width: rect.width,
            height: rect.height,
          };
        })
      );
      rects.forEach((it) => {
        engine.componentFactory.callbackTextMeasureResult(it.measureId, it);
      });
    }
  }
}
