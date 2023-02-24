import { ComponentView } from "./components/component_view";
import { setDOMStyle } from "./components/dom_utils";
import { MPScaffold, MPScaffoldDelegate } from "./components/mpkit/scaffold";
import { Engine } from "./engine";
import { MPEnv, PlatformType } from "./env";
import { Router } from "./router";

export class Page {
  private _active = true;
  private scaffoldView?: MPScaffold;
  private readyCallback?: (_: any) => void;
  viewId: number = -1;
  overlaysView: ComponentView[] = [];
  isFirst: boolean = false;
  miniProgramPage: any;
  bodyElement: HTMLElement;
  overlayElement: HTMLElement;

  constructor(
    readonly element: HTMLElement,
    readonly engine: Engine,
    readonly options?: { route: string; params: any },
    readonly document: Document = self?.document
  ) {
    this.bodyElement = __MP_TARGET_BROWSER__ ? element : document.createElement("wx-view");
    this.overlayElement = __MP_TARGET_BROWSER__ ? element : document.createElement("wx-view");
    if (this.bodyElement !== element || this.overlayElement !== element) {
      this.element.appendChild(this.bodyElement);
      this.element.appendChild(this.overlayElement);
    }
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
    if (__MP_TARGET_WEAPP__) {
      this.element.getBoundingClientRect = (this.element as any).$$getBoundingClientRect;
    }
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
    if (__MP_MINI_PROGRAM__) {
      await this.delay();
    }
    const viewport = await this.fetchViewport();
    return router!.requestRoute(
      this.options?.route ?? "/",
      this.options?.params,
      this.isFirst || this.engine.app === undefined,
      { width: viewport.width, height: viewport.height }
    );
  }

  async delay() {
    return new Promise((it) => {
      setTimeout(() => {
        it(null);
      }, 1000);
    });
  }

  async fetchViewport() {
    if (__MP_TARGET_TT__) {
      return {
        width: MPEnv.platformScope.getSystemInfoSync().windowWidth,
        height: MPEnv.platformScope.getSystemInfoSync().windowHeight,
      };
    }
    let viewport = { ...(await (this.element as any).getBoundingClientRect()) };
    if (!viewport.width || viewport.width <= 0.1) {
      if (__MP_MINI_PROGRAM__) {
        viewport.width = MPEnv.platformScope.getSystemInfoSync().windowWidth;
      } else {
        viewport.width = window.innerWidth;
      }
    }
    if (!viewport.height || viewport.height <= 0.1) {
      if (__MP_MINI_PROGRAM__) {
        viewport.height = MPEnv.platformScope.getSystemInfoSync().windowHeight;
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

  async didReceivedFrameData(message: { [key: string]: any }) {
    if (!message.overlays || (message.overlays && message.overlays instanceof Array && message.overlays.length === 0)) {
      if (this.overlaysView.length > 0) {
        this.overlaysView.forEach((it) => {
          it.htmlElement.style.visibility = "hidden";
        });
        await this.removeOverlays();
      }
    }
    if (message.ignoreScaffold !== true) {
      const scaffoldView = this.engine.componentFactory.create(message.scaffold, this.document);
      if (!(scaffoldView instanceof MPScaffold)) return;
      if (this.scaffoldView !== scaffoldView) {
        if (this.scaffoldView) {
          this.scaffoldView.attached = false;
          this.scaffoldView.htmlElement.remove();
          this.scaffoldView.removeFromSuperview();
        }
        this.scaffoldView = scaffoldView;
        if (scaffoldView instanceof MPScaffold && !scaffoldView.delegate) {
          if (__MP_MINI_PROGRAM__) {
            if (__MP_MINI_PROGRAM__) {
              scaffoldView.setDelegate(new WXPageScaffoldDelegate(this.document, this.miniProgramPage));
              scaffoldView.setAttributes(message.scaffold.attributes);
            }
          } else {
            if (__MP_TARGET_BROWSER__) {
              scaffoldView.setDelegate(new BrowserPageScaffoldDelegate(this.document, scaffoldView));
              scaffoldView.setAttributes(message.scaffold.attributes);
            }
          }
        }
      }
      if (this.scaffoldView && this.active && !this.scaffoldView.attached) {
        this.scaffoldView.attached = true;
        this.bodyElement.appendChild(this.scaffoldView.htmlElement);
        setDOMStyle(this.scaffoldView.htmlElement, { display: "contents" });
      }
    }
    if (message.overlays && message.overlays instanceof Array) {
      this.setOverlays(message.overlays);
    }
    if (this.miniProgramPage && !this.miniProgramPage.didReceivedFirstFrame) {
      this.miniProgramPage.setData({ didReceivedFirstFrame: true });
      this.miniProgramPage.didReceivedFirstFrame = true;
    }
  }

  async onRefresh() {
    if (this.scaffoldView instanceof MPScaffold) {
      await this.scaffoldView.onRefresh();
    }
  }

  async onWechatMiniProgramShareAppMessage(info: any) {
    if (this.scaffoldView instanceof MPScaffold) {
      return await this.scaffoldView.onWechatMiniProgramShareAppMessage(info);
    }
  }

  onWechatMiniProgramShareTimeline() {
    if (this.scaffoldView instanceof MPScaffold) {
      return this.scaffoldView.onWechatMiniProgramShareTimeline();
    }
  }

  onWechatMiniProgramAddToFavorites(info: any) {
    if (this.scaffoldView instanceof MPScaffold) {
      return this.scaffoldView.onWechatMiniProgramAddToFavorites();
    }
  }

  onReachBottom() {
    if (this.scaffoldView instanceof MPScaffold) {
      this.scaffoldView.onReachBottom();
    }
  }

  onPageScroll(scrollTop: number) {
    if (this.scaffoldView instanceof MPScaffold) {
      this.scaffoldView.onPageScroll(scrollTop);
    }
  }

  async removeOverlays() {
    return new Promise((res) => {
      this.overlaysView.forEach((it) => {
        it.removeFromSuperview();
        setTimeout(() => {
          it.htmlElement.remove();
        }, 300);
      });
      this.overlaysView = [];
      setTimeout(() => {
        res(null);
      }, 100);
    });
  }

  setOverlays(overlays: any[]) {
    let overlaysView = overlays
      .map((it) => this.engine.componentFactory.create(it, this.document))
      .filter((it) => it) as ComponentView[];
    if (
      overlaysView.length === this.overlaysView.length &&
      overlaysView.every((it, idx) => overlaysView[idx] === this.overlaysView[idx])
    ) {
      return;
    }
    this.overlaysView.forEach((it) => {
      it.removeFromSuperview();
      setTimeout(() => {
        it.htmlElement.remove();
      }, 300);
    });
    overlaysView.forEach((it) => {
      this.overlayElement.appendChild(it.htmlElement);
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
        this.overlaysView.forEach((it) => it.htmlElement.remove());
      }
    } else {
      if (this.scaffoldView?.htmlElement) {
        this.element.appendChild(this.scaffoldView.htmlElement);
        this.overlaysView.forEach((it) => {
          this.overlayElement.appendChild(it.htmlElement);
        });
        this.scaffoldView.setAttributes(this.scaffoldView.attributes);
      }
    }
  }
}

class BrowserPageScaffoldDelegate implements MPScaffoldDelegate {
  observingScroller = false;

  constructor(readonly document: Document, readonly scaffoldView: MPScaffold) {
    this.installPageScrollListener();
  }

  setPageTitle(title: string): void {
    this.document.title = title;
  }

  setPageBackgroundColor(color: string): void {
    this.document.body.style.backgroundColor = color;
  }

  setAppBarColor(color: string, tintColor?: string): void {}

  installPageScrollListener() {
    var eventListener: any;
    eventListener = (e: any) => {
      if (!this.scaffoldView.htmlElement.isConnected) {
        this.observingScroller = false;
        window.removeEventListener("scroll", eventListener);
        return;
      }
      this.scaffoldView.onPageScroll(window.scrollY);
    };
    if (!this.observingScroller) {
      this.observingScroller = true;
      window.addEventListener("scroll", eventListener);
    }
  }
}

class WXPageScaffoldDelegate implements MPScaffoldDelegate {
  constructor(readonly document: Document, readonly miniProgramPage: any) {}

  backgroundElement = this.document.createElement("div");
  backgroundElementAttached = false;

  setPageTitle(title: string): void {
    if (MPEnv.platformByteDance()) {
      MPEnv.platformScope.setNavigationBarTitle({ title });
      MPEnv.platformScope.setNavigationBarColor({
        frontColor: "#000000",
        backgroundColor: "#ffffff",
      });
      return;
    }
    if (MPEnv.platformPC()) {
      MPEnv.platformScope.setNavigationBarTitle({ title });
    }
    this.miniProgramPage.setData({
      "pageMeta.naviBar.title": title,
    });
  }

  setPageBackgroundColor(color: string): void {
    if (color === "transparent") {
      this.backgroundElement.remove();
      this.backgroundElementAttached = false;
      return;
    }
    setDOMStyle(this.backgroundElement, {
      position: "fixed",
      width: "100vw",
      height: "100vh",
      zIndex: "-1",
      backgroundColor: color,
    });
    if (this.backgroundElementAttached) return;
    this.document.body.appendChild(this.backgroundElement);
    this.backgroundElementAttached = true;
  }

  setAppBarColor(color: string, tintColor?: string): void {
    if (MPEnv.platformByteDance()) {
      MPEnv.platformScope.setNavigationBarColor({
        frontColor: tintColor,
        backgroundColor: color,
      });
      return;
    }
    if (MPEnv.platformPC()) {
      MPEnv.platformScope.setNavigationBarColor({ frontColor: tintColor, backgroundColor: color });
    }
    this.miniProgramPage.setData({
      "pageMeta.naviBar.backgroundColor": color,
      "pageMeta.naviBar.frontColor": tintColor,
    });
  }
}
