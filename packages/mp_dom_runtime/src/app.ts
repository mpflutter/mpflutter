import { Engine } from "./engine";
import { Page } from "./page";
import { BrowserRouter, WXRouter } from "./router";

export class BrowserApp {
  router: BrowserRouter = new BrowserRouter(this.engine);

  constructor(readonly rootElement: HTMLElement, readonly engine: Engine) {
    engine.app = this;
    this.setupPageScrollListener();
  }

  private setupPageScrollListener() {
    document.addEventListener("scroll", () => {
      if (
        document.documentElement.scrollHeight > innerHeight &&
        window.pageYOffset + innerHeight >=
          document.documentElement.scrollHeight
      ) {
        let history = (this.engine.app?.router as BrowserRouter).history;
        history[history.length - 1].item.onReachBottom();
      }
    });
  }

  getURLSearchParams(): any {
    try {
      let result: any = {};
      let searchParams = new URL(window.location.href).searchParams as any;
      const keys = searchParams.keys();
      let next = keys.next();
      while (!next.done) {
        result[next.value] = searchParams.get(next.value);
        next = keys.next();
        if (next.done) break;
      }
      return result;
    } catch (error) {
      console.error(error);
      return {};
    }
  }

  async setupFirstPage(
    options?: {
      route: string;
      params: any;
    },
    reset?: boolean
  ) {
    if (!options) {
      if (this.router.isPathRewriteEnabled) {
        options = {
          route: new URL(window.location.href).pathname || "/",
          params: this.getURLSearchParams(),
        };
      } else {
        let params = { ...this.getURLSearchParams() };
        delete params["route"];
        options = {
          route: new URL(window.location.href).searchParams.get("route") || "/",
          params: params,
        };
      }
    }
    const firstPage = new Page(this.rootElement, this.engine, options);
    firstPage.isFirst = true;
    if (reset) {
      this.router.history.forEach((it) => (it.item.active = false));
      this.router.history[0] = {
        item: firstPage,
        scrollPosition: 0,
      };
    } else {
      this.router.history.push({
        item: firstPage,
        scrollPosition: 0,
      });
    }
    await firstPage.ready();
    this.router.didSetupFirst(
      firstPage.viewId,
      options?.route ?? "/",
      options?.params ?? {}
    );
  }

  enablePathRewrite() {
    this.router.isPathRewriteEnabled = true;
  }
}

export class WXApp {
  router: WXRouter = new WXRouter(this.engine);

  constructor(readonly indexPage: string, readonly engine: Engine) {
    engine.app = this;
  }
}
