import { PluginRegister } from "./platform_channel/plugin_register";
import { MPMethodChannel } from "./platform_channel/mp_method_channel";
import { Engine } from "./engine";
import { Page } from "./page";
import { Router } from "./router";

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
        window.pageYOffset + innerHeight >= document.documentElement.scrollHeight
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
    this.router.didSetupFirst(firstPage.viewId, options?.route ?? "/", options?.params ?? {});
  }

  enablePathRewrite() {
    this.router.isPathRewriteEnabled = true;
  }
}

class BrowserRouter extends Router {
  history: { item: Page; scrollPosition: number }[] = [];
  isPathRewriteEnabled = false;
  private doBacking = false;

  constructor(engine: Engine) {
    super(engine);
    window.addEventListener("popstate", (_) => {
      if (this.doBacking) {
        return true;
      }
      if (window.history.state && window.history.state.routeId) {
        let routeId = window.history.state.routeId;
        if (this.history.length > 1) {
          this.popHistory();
          this.engine.sendMessage(
            JSON.stringify({
              type: "router",
              message: { event: "popToRoute", routeId },
            })
          );
        } else {
          if (this.engine.app && this.engine.app instanceof BrowserApp) {
            this.engine.app.setupFirstPage(undefined, true);
          }
        }
      }
    });
  }

  encodePath(name: string, params?: any): string {
    let searchParams: string[] = [];
    if (params) {
      for (const key in params) {
        searchParams.push(`${key}=${encodeURIComponent(params[key])}`);
      }
    }
    if (this.isPathRewriteEnabled) {
      if (searchParams.length > 0) {
        return `${name}?${searchParams.join("&")}`;
      } else {
        return `${name}`;
      }
    } else {
      const namePath = name.indexOf("?") >= 0 ? name.split("?")[0] : name;
      const paramPath = name.indexOf("?") >= 0 ? name.substr(name.indexOf("?")) : "";
      if (searchParams.length > 0) {
        return `?route=${encodeURI(namePath)}${encodeURIComponent(paramPath)}&${searchParams.join("&")}`;
      } else {
        return `?route=${encodeURI(namePath)}${encodeURIComponent(paramPath)}`;
      }
    }
  }

  didSetupFirst(routeId: number, name: string, params: any) {
    window.history.replaceState({ routeId }, "", this.encodePath(name, params));
  }

  didPush(message: any) {
    const routeId = message.routeId;
    this.thePushingRouteId = routeId;
    const name = message.name;
    window.history.pushState({ routeId }, "", this.encodePath(name, message.params));
    const scrollTop = window.pageYOffset;
    const nextPage = new Page((this.engine.app as BrowserApp).rootElement, this.engine);
    this.pushHistory(nextPage, scrollTop);
  }

  didReplace(message: any) {
    const routeId = message.routeId;
    this.thePushingRouteId = routeId;
    const name = message.name;
    window.history.replaceState({ routeId }, "", this.encodePath(name, message.params));
    const nextPage = new Page((this.engine.app as BrowserApp).rootElement, this.engine);
    this.replaceHistory(nextPage);
  }

  didPop() {
    this.doBacking = true;
    window.history.back();
    this.popHistory();
    setTimeout(() => {
      this.doBacking = false;
    }, 100);
  }

  pushHistory(item: Page, scrollPosition: number) {
    this.history.forEach((it) => (it.item.active = false));
    this.history.push({ item, scrollPosition });
    window.scrollTo(0, 0);
  }

  replaceHistory(item: Page) {
    this.history.forEach((it) => (it.item.active = false));
    this.history[this.history.length - 1] = {
      item,
      scrollPosition: 0,
    };
    window.scrollTo(0, 0);
  }

  popHistory() {
    if (this.history.length <= 1) return;
    this.history.pop()!.item.active = false;
    this.history[this.history.length - 1].item.active = true;
    window.scrollTo(0, this.history[this.history.length - 1].scrollPosition);
  }
}

class FlutterPlatformChannel extends MPMethodChannel {
  async onMethodCall(method: string, params: any) {
    if (method === "Clipboard.setData") {
      const copyText = document.createElement("input");
      document.body.appendChild(copyText);
      copyText.value = params.text;
      copyText.select();
      document.execCommand("Copy");
      copyText.remove();
      return null;
    } else if (method === "Clipboard.getData") {
      throw "The operation of getData from clip board is not allow in browser.";
    } else if (method === "RootBundle.getAssets") {
      return new Promise((resolver, rejector) => {
        const request = new XMLHttpRequest();
        request.responseType = "blob";
        request.open("GET", `/assets/${decodeURIComponent(params.uri)}`);
        request.onloadend = () => {
          const blobReader = new FileReader();
          blobReader.onloadend = () => {
            resolver((blobReader.result as string).split("base64,")[1]);
          };
          blobReader.readAsDataURL(request.response);
        };
        request.onerror = () => {
          rejector(request.statusText);
        };
        request.send();
      });
    } else {
      throw "NOTIMPLEMENTED";
    }
  }
}

PluginRegister.registerChannel("flutter/platform", FlutterPlatformChannel);
