import { Engine } from "../engine";
import { ClipOval } from "./basic/clip_oval";
import { ColoredBox } from "./basic/colored_box";
import { Offstage } from "./basic/offstage";
import { Opacity } from "./basic/opacity";
import { Transform } from "./basic/transform";
import { RichText, TextSpan, WidgetSpan } from "./basic/rich_text";
import { Image } from "./basic/image";
import { Visibility } from "./basic/visibility";
import { ComponentView } from "./component_view";
import { MPScaffold } from "./mpkit/scaffold";

export class CanvasComponentFactory {
  static components: { [key: string]: typeof ComponentView } = {
    clip_oval: ClipOval,
    colored_box: ColoredBox,
    opacity: Opacity,
    offstage: Offstage,
    visibility: Visibility,
    transform: Transform,
    image: Image,
    rich_text: RichText,
    text_span: TextSpan,
    widget_span: WidgetSpan,
    mp_scaffold: MPScaffold,
  };

  // static ancestors: { [key: string]: typeof AncestorView } = {

  // };

  static disableCache = false;

  cachedView: { [key: number]: ComponentView } = {};
  // cachedAncestor: { [key: number]: AncestorView } = {};
  cachedElement: { [key: number]: any } = {};
  private textMeasureResults: {
    measureId: number;
    size: { width: number; height: number };
  }[] = [];

  constructor(readonly engine: Engine) { }

  create(data: any): ComponentView | undefined {
    if (!data) return undefined;
    const same = data["^"];
    const name = data.name;
    const hashCode = data.hashCode;
    if (same == 1 && typeof hashCode === "number") {
      return this.cachedView[hashCode];
    }
    if (!name || !hashCode) {
      return undefined;
    }
    if (!same) {
      this.cachedElement[hashCode] = data;
    }
    const cachedView = !CanvasComponentFactory.disableCache && this.cachedView[hashCode];
    if (cachedView) {
      // document = cachedView.document;
      // if (data.ancestors) {
      //     cachedView.setAncestors(data.ancestors);
      // }
      if (data.constraints) {
        cachedView.setConstraints(data.constraints);
      }
      if (data.attributes) {
        cachedView.setAttributes(data.attributes);
      }
      if (data.children) {
        cachedView.setChildren(this.fetchCachedChildren(data.children));
      }
      return cachedView;
    }
    if (!document) return;
    let clazz = CanvasComponentFactory.components[name];
    if (!clazz) {
      clazz = ComponentView;
    }
    const view = new clazz(data.attributes);
    view.factory = this;
    view.engine = this.engine;
    view.hashCode = hashCode;
    // if (data.ancestors) {
    //     view.setAncestors(data.ancestors);
    // }
    if (data.constraints) {
      view.setConstraints(data.constraints);
    }
    if (data.attributes) {
      view.setAttributes(data.attributes);
    }
    if (data.children) {
      if (CanvasComponentFactory.disableCache) {
        view.setChildren(data.children);
      } else {
        view.setChildren(this.fetchCachedChildren(data.children));
      }
    }
    if (!CanvasComponentFactory.disableCache) {
      this.cachedView[hashCode] = view;
    }
    return view;
  }

  // createAncestors(data: any, target: ComponentView): AncestorView | undefined {
  //     const same = data["^"];
  //     const name = data.name;
  //     const hashCode = data.hashCode;
  //     if (same == 1 && typeof hashCode === "number") {
  //         return this.cachedAncestor[hashCode];
  //     }
  //     if (!name || !hashCode) {
  //         return undefined;
  //     }
  //     if (!same) {
  //         this.cachedElement[hashCode] = data;
  //     }
  //     const cachedAncestor = this.cachedAncestor[hashCode];
  //     if (cachedAncestor) {
  //         if (cachedAncestor.target && cachedAncestor.target !== target) {
  //             const idx = cachedAncestor.target.ancestors.indexOf(cachedAncestor);
  //             if (idx >= 0) cachedAncestor.target.ancestors.splice(idx, 1);
  //         }
  //         cachedAncestor.target = target;
  //         if (data.attributes) {
  //             cachedAncestor.setAttributes(data.attributes);
  //         }
  //         if (data.constraints) {
  //             cachedAncestor.setConstraints(data.constraints);
  //         }
  //         return cachedAncestor;
  //     }
  //     if (!target) return;
  //     let clazz = ComponentFactory.ancestors[name];
  //     if (!clazz) {
  //         return undefined;
  //     }
  //     const ancestor = new clazz(target);
  //     if (data.attributes) {
  //         ancestor.setAttributes(data.attributes);
  //     }
  //     if (data.constraints) {
  //         ancestor.setConstraints(data.constraints);
  //     }
  //     this.cachedAncestor[hashCode] = ancestor;
  //     return ancestor;
  // }

  fetchCachedChildren(children: any[]) {
    return children.map((it: any) => {
      let same = it["^"];
      let hashCode = it["hashCode"];
      if (same && this.cachedElement[hashCode]) {
        return this.cachedElement[hashCode];
      } else {
        return it;
      }
    });
  }

  private markedNeedsFlushTextMeasureResult = false;

  callbackTextMeasureResult(measureId: number, size: { width: number; height: number }) { }

  callbackTextPainterMeasureResult(seqId: number, size: { width: number; height: number }) { }

  flushTextMeasureResult() { }
}
