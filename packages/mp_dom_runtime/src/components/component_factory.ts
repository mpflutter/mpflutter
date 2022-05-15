import { Engine } from "../engine";
import { AbsorbPointer } from "./basic/absorb_pointer";
import { ClipOval } from "./basic/clip_oval";
import { ClipRRect, ClipRRectAncestor } from "./basic/clip_r_rect";
import { ColoredBox } from "./basic/colored_box";
import { DecoratedBox } from "./basic/decorated_box";
import { GestureDetector } from "./basic/gesture_detector";
import { IgnorePointer } from "./basic/ignore_pointer";
import { Offstage } from "./basic/offstage";
import { Opacity, OpacityAncestor } from "./basic/opacity";
import { Transform } from "./basic/transform";
import { Image } from "./basic/image";
import { AncestorView, ComponentView } from "./component_view";
import { MPScaffold } from "./mpkit/scaffold";
import { RichText, TextSpan, WidgetSpan } from "./basic/rich_text";
import { ListView } from "./basic/list_view";
import { GridView } from "./basic/grid_view";
import { CustomScrollView } from "./basic/custom_scroll_view";
import { CustomPaint } from "./basic/custom_paint";
import { MPIcon } from "./mpkit/icon";
import { MPVideoView } from "./mpkit/video_view";
import { MPWebView } from "./mpkit/web_view";
import { MPPageView } from "./mpkit/page_view";
import { MPMiniProgramView } from "./mpkit/miniprogram_view";
import { Overlay } from "./basic/overlay";
import { Visibility } from "./basic/visibility";
import { SliverPersistentHeader } from "./basic/sliver_persistent_header";
import { EditableText } from "./basic/editable_text";
import { MPPlatformView } from "./mpkit/platform_view";
import { ForegroundDecoratedBox } from "./basic/foreground_decorated_box";
import { MPEnv } from "../env";
import { MPSwitch } from "./mpkit/switch";
import { MPSlider } from "./mpkit/slider";
import { MPPicker } from "./mpkit/picker";
import { MPDatePicker } from "./mpkit/date_picker";
import { MPCircularProgressIndicator } from "./mpkit/circular_progress_indicator";
import { MouseRegion } from "./basic/mouse_region";

export class ComponentFactory {
  static components: { [key: string]: typeof ComponentView } = {
    absorb_pointer: AbsorbPointer,
    clip_oval: ClipOval,
    clip_r_rect: ClipRRect,
    colored_box: ColoredBox,
    custom_paint: CustomPaint,
    custom_scroll_view: CustomScrollView,
    decorated_box: DecoratedBox,
    foreground_decorated_box: ForegroundDecoratedBox,
    editable_text: EditableText,
    gesture_detector: GestureDetector,
    grid_view: GridView,
    ignore_pointer: IgnorePointer,
    image: Image,
    list_view: ListView,
    mouse_region: MouseRegion,
    offstage: Offstage,
    opacity: Opacity,
    overlay: Overlay,
    rich_text: RichText,
    text_span: TextSpan,
    widget_span: WidgetSpan,
    sliver_persistent_header: SliverPersistentHeader,
    transform: Transform,
    visibility: Visibility,
    mp_icon: MPIcon,
    mp_scaffold: MPScaffold,
    mp_video_view: MPVideoView,
    mp_web_view: MPWebView,
    mp_page_view: MPPageView,
    mp_platform_view: MPPlatformView,
    mp_switch: MPSwitch,
    mp_slider: MPSlider,
    mp_picker: MPPicker,
    mp_date_picker: MPDatePicker,
    mp_mini_program_view: MPMiniProgramView,
    mp_circular_progress_indicator: MPCircularProgressIndicator,
  };

  static ancestors: { [key: string]: typeof AncestorView } = {
    opacity: OpacityAncestor,
    clip_r_rect: ClipRRectAncestor,
  };

  static disableCache = false;

  cachedView: { [key: number]: ComponentView } = {};
  cachedAncestor: { [key: number]: AncestorView } = {};
  cachedElement: { [key: number]: any } = {};
  private textMeasureResults: {
    measureId: number;
    size: { width: number; height: number };
  }[] = [];

  constructor(readonly engine: Engine) {}

  create(data: any, document: Document): ComponentView | undefined {
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
    const cachedView = !ComponentFactory.disableCache && this.cachedView[hashCode];
    if (cachedView) {
      document = cachedView.document;
      if (data.ancestors) {
        cachedView.setAncestors(data.ancestors);
      }
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
    let clazz = ComponentFactory.components[name];
    if (!clazz) {
      clazz = ComponentView;
    }
    const view = new clazz(document, data.attributes);
    if (MPEnv.platformGlobal()?.mpDEBUG) {
      view.htmlElement.setAttribute("mp-component", name);
    }
    view.factory = this;
    view.engine = this.engine;
    view.hashCode = hashCode;
    if (data.ancestors) {
      view.setAncestors(data.ancestors);
    }
    if (data.constraints) {
      view.setConstraints(data.constraints);
    }
    if (data.attributes) {
      view.setAttributes(data.attributes);
    }
    if (data.children) {
      if (ComponentFactory.disableCache) {
        view.setChildren(data.children);
      } else {
        view.setChildren(this.fetchCachedChildren(data.children));
      }
    }
    if (!ComponentFactory.disableCache) {
      this.cachedView[hashCode] = view;
    }
    return view;
  }

  createAncestors(data: any, target: ComponentView): AncestorView | undefined {
    const same = data["^"];
    const name = data.name;
    const hashCode = data.hashCode;
    if (same == 1 && typeof hashCode === "number") {
      return this.cachedAncestor[hashCode];
    }
    if (!name || !hashCode) {
      return undefined;
    }
    if (!same) {
      this.cachedElement[hashCode] = data;
    }
    const cachedAncestor = this.cachedAncestor[hashCode];
    if (cachedAncestor) {
      if (cachedAncestor.target && cachedAncestor.target !== target) {
        const idx = cachedAncestor.target.ancestors.indexOf(cachedAncestor);
        if (idx >= 0) cachedAncestor.target.ancestors.splice(idx, 1);
      }
      cachedAncestor.target = target;
      if (data.attributes) {
        cachedAncestor.setAttributes(data.attributes);
      }
      if (data.constraints) {
        cachedAncestor.setConstraints(data.constraints);
      }
      return cachedAncestor;
    }
    if (!target) return;
    let clazz = ComponentFactory.ancestors[name];
    if (!clazz) {
      return undefined;
    }
    const ancestor = new clazz(target);
    if (data.attributes) {
      ancestor.setAttributes(data.attributes);
    }
    if (data.constraints) {
      ancestor.setConstraints(data.constraints);
    }
    this.cachedAncestor[hashCode] = ancestor;
    return ancestor;
  }

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

  callbackTextMeasureResult(measureId: number, size: { width: number; height: number }) {
    this.textMeasureResults.push({ measureId, size });
    if (!this.markedNeedsFlushTextMeasureResult) {
      this.markedNeedsFlushTextMeasureResult = true;
      setTimeout(() => {
        this.flushTextMeasureResult();
        this.markedNeedsFlushTextMeasureResult = false;
      }, 50);
    }
  }

  callbackTextPainterMeasureResult(seqId: number, size: { width: number; height: number }) {
    this.engine.sendMessage(
      JSON.stringify({
        type: "rich_text",
        message: { event: "onTextPainterMeasured", data: { seqId, size } },
      })
    );
  }

  flushTextMeasureResult() {
    if (this.textMeasureResults.length > 0) {
      this.engine.sendMessage(
        JSON.stringify({
          type: "rich_text",
          message: { event: "onMeasured", data: this.textMeasureResults },
        })
      );
      this.textMeasureResults = [];
    }
  }
}
