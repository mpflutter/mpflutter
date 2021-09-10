declare var global: any;
declare var wx: any;
declare var getCurrentPages: any;

import { WXApp } from "./app";
import { ComponentFactory } from "./components/component_factory";
import { ComponentView } from "./components/component_view";
import { setDOMStyle } from "./components/dom_utils";
import { MPScaffold, MPScaffoldDelegate } from "./components/mpkit/scaffold";
import { Engine } from "./engine";
import { MPEnv, PlatformType } from "./env";
import { Router } from "./router";
import { TextMeasurer } from "./text_measurer";

export class Page {
  private _active = true;
  private scaffoldView?: MPScaffold;
  private readyCallback?: (_: any) => void;
  viewId: number = -1;
  overlaysView: ComponentView[] = [];
  isFirst: boolean = false;

  constructor(
    readonly element: HTMLElement,
    readonly engine: Engine,
    readonly options?: { route: string; params: any },
    readonly document: Document = self?.document
  ) {
    this.requestRoute().then((viewId: number) => {
      this.viewId = viewId;
      engine.managedViews[this.viewId] = this;
      engine.pageMode = true;
      if (engine.unmanagedViewFrameData[this.viewId]) {
        engine.unmanagedViewFrameData[this.viewId].forEach((it) => {
          this.didReceivedFrameData(it);
        });
        delete engine.unmanagedViewFrameData[this.viewId];
      }
      this.readyCallback?.(undefined);
    });
  }

  async ready(): Promise<any> {
    return new Promise((res) => {
      this.readyCallback = res;
    });
  }

  async requestRoute(): Promise<number> {
    if (!this.engine.app) {
      this.engine.router = new Router(this.engine);
    }
    const router = this.engine.app?.router ?? this.engine?.router;
    const viewport = await this.fetchViewport();
    return router!.requestRoute(
      this.options?.route ?? "/",
      this.options?.params,
      this.isFirst || this.engine.app === undefined,
      { width: viewport.width, height: viewport.height }
    );
  }

  async fetchViewport() {
    let viewport = await this.element.getBoundingClientRect();
    if (viewport.height <= 0.1) {
      if (MPEnv.platformType === PlatformType.wxMiniProgram) {
        viewport.height = wx.getSystemInfoSync().windowHeight;
      } else {
        viewport.height = window.innerHeight;
      }
    }
    return viewport;
  }

  dispose() {
    delete this.engine.managedViews[this.viewId];
  }

  async viewportChanged() {
    const router = this.engine.app?.router ?? this.engine?.router;
    if (router) {
      const viewport = await this.fetchViewport();
      router.updateRoute(this.viewId, {
        width: viewport.width,
        height: viewport.height,
      });
    }
  }

  didReceivedFrameData(message: { [key: string]: any }) {
    if (message.ignoreScaffold !== true) {
      const scaffoldView = this.engine.componentFactory.create(
        message.scaffold,
        this.document
      );
      if (!(scaffoldView instanceof MPScaffold)) return;
      if (this.scaffoldView !== scaffoldView) {
        if (this.scaffoldView) {
          this.scaffoldView.htmlElement.remove();
          this.scaffoldView.removeFromSuperview();
        }
        this.scaffoldView = scaffoldView;
        if (scaffoldView instanceof MPScaffold && !scaffoldView.delegate) {
          if (MPEnv.platformType === PlatformType.wxMiniProgram) {
            scaffoldView.setDelegate(new WXPageScaffoldDelegate(this.document));
            scaffoldView.setAttributes(message.scaffold.attributes);
          } else {
            scaffoldView.setDelegate(
              new BrowserPageScaffoldDelegate(this.document)
            );
            scaffoldView.setAttributes(message.scaffold.attributes);
          }
        }
      }
      if (this.scaffoldView && this.active && !this.scaffoldView.attached) {
        this.scaffoldView.attached = true;
        this.element.appendChild(this.scaffoldView.htmlElement);
        setDOMStyle(this.scaffoldView.htmlElement, { display: "contents" });
      }
    }
    if (message.overlays && message.overlays instanceof Array) {
      this.setOverlays(message.overlays);
    }
  }

  async onRefresh() {
    if (this.scaffoldView instanceof MPScaffold) {
      await this.scaffoldView.onRefresh();
    }
  }

  async onWechatMiniProgramShareAppMessage() {
    if (this.scaffoldView instanceof MPScaffold) {
      return await this.scaffoldView.onWechatMiniProgramShareAppMessage();
    }
  }

  onReachBottom() {
    if (this.scaffoldView instanceof MPScaffold) {
      this.scaffoldView.onReachBottom();
    }
  }

  setOverlays(overlays: any[]) {
    this.overlaysView.forEach((it) => {
      it.htmlElement.remove();
      it.removeFromSuperview();
    });
    let overlaysView = overlays
      .map((it) => this.engine.componentFactory.create(it, this.document))
      .filter((it) => it) as ComponentView[];
    overlaysView.forEach((it) => {
      this.document.body.appendChild(it.htmlElement);
    });
    this.overlaysView = overlaysView;
  }

  public get active() {
    return this._active;
  }

  public set active(value) {
    this._active = value;
    if (!value) {
      if (this.scaffoldView) {
        this.scaffoldView.attached = false;
        this.scaffoldView.htmlElement.remove();
      }
    } else {
      if (this.scaffoldView?.htmlElement) {
        this.element.appendChild(this.scaffoldView.htmlElement);
        this.scaffoldView.setAttributes(this.scaffoldView.attributes);
      }
    }
  }
}

export class BrowserPageScaffoldDelegate implements MPScaffoldDelegate {
  constructor(readonly document: Document) {}

  setPageTitle(title: string): void {
    this.document.title = title;
  }

  setPageBackgroundColor(color: string): void {
    this.document.body.style.backgroundColor = color;
  }

  setAppBarColor(color: string, tintColor?: string): void {}
}

export class WXPageScaffoldDelegate implements MPScaffoldDelegate {
  constructor(readonly document: Document) {}

  backgroundElement = this.document.createElement("div");

  setPageTitle(title: string): void {
    wx.setNavigationBarTitle({ title });
  }

  setPageBackgroundColor(color: string): void {
    setDOMStyle(this.backgroundElement, {
      position: "fixed",
      width: "100vw",
      height: "100vh",
      zIndex: "-1",
      backgroundColor: color,
    });
    this.document.body.appendChild(this.backgroundElement);
    wx.setBackgroundColor({ backgroundColor: color });
  }

  setAppBarColor(color: string, tintColor?: string): void {
    wx.setNavigationBarColor({ backgroundColor: color, frontColor: tintColor });
  }
}

export const WXPage = (
  options: { route: string; params: any } | undefined,
  selector: string = "#vdom",
  app: WXApp = global.app
) => {
  return {
    onLoad(pageOptions: any) {
      const document = (this as any).selectComponent(selector).miniDom.document;
      const documentTm = (this as any).selectComponent(selector + "_tm").miniDom
        .document;
      TextMeasurer.activeTextMeasureDocument = documentTm;
      const basePath = (() => {
        let c = app.indexPage.split("/");
        c.pop();
        return c.join("/");
      })();
      let finalOptions = options;
      if (!options || pageOptions.route) {
        let params = { ...pageOptions };
        delete params["route"];
        if (pageOptions.route) {
          finalOptions = { route: pageOptions.route, params: params };
        } else {
          finalOptions = {
            route: (this as any).route.replace(basePath, ""),
            params: params,
          };
          if (finalOptions.route === "/index") {
            finalOptions.route = "/";
          }
        }
      }
      if (finalOptions?.route) {
        finalOptions.route = decodeURIComponent(finalOptions.route);
      }

      (this as any).mpPage = new Page(
        document.body,
        app.engine,
        finalOptions,
        document
      );
      (this as any).mpPage.isFirst = getCurrentPages().length === 1;
    },
    onUnload() {
      if ((this as any).mpPage.viewId) {
        app.router.disposeRoute((this as any).mpPage.viewId);
      }
    },
    onShow() {
      TextMeasurer.activeTextMeasureDocument = (this as any).selectComponent(
        selector + "_tm"
      ).miniDom.document;
    },
    onPullDownRefresh() {
      (this as any).mpPage.onRefresh().then((it: any) => {
        wx.stopPullDownRefresh();
      });
    },
    onShareAppMessage() {
      return {
        promise: (this as any).mpPage.onWechatMiniProgramShareAppMessage(),
      };
    },
    onReachBottom() {
      (this as any).mpPage.onReachBottom();
    },
  };
};
