import { BrowserApp, WXApp } from "./app";
import { Engine } from "./engine";
import { MPEnv } from "./env";
import { Page } from "./page";

export class Router {
  static beingPush = false;

  constructor(readonly engine: Engine) {}

  routeResponseHandler: { [key: string]: (routeId: number) => void } = {};
  thePushingRouteId: number | undefined;

  async updateRoute(
    routeId: number,
    viewport: { width: number; height: number }
  ) {
    this.engine.sendMessage(
      JSON.stringify({
        type: "router",
        message: {
          event: "updateRoute",
          routeId,
          viewport,
        },
      })
    );
  }

  async requestRoute(
    name: string,
    params: any,
    root: boolean,
    viewport: { width: number; height: number }
  ): Promise<number> {
    if (this.thePushingRouteId) {
      let value = this.thePushingRouteId;
      this.thePushingRouteId = undefined;
      this.engine.sendMessage(
        JSON.stringify({
          type: "router",
          message: {
            event: "updateRoute",
            routeId: value,
            viewport,
          },
        })
      );
      return value;
    }
    let requestId = Math.random().toString();
    return new Promise((res) => {
      this.routeResponseHandler[requestId] = res;
      this.engine.sendMessage(
        JSON.stringify({
          type: "router",
          message: {
            event: "requestRoute",
            requestId,
            name,
            params: params ?? {},
            viewport,
            root: root === true,
          },
        })
      );
    });
  }

  responseRoute(message: any) {
    let requestId = message.requestId;
    let routeId = message.routeId;
    this.routeResponseHandler[requestId]?.call(this, routeId);
  }

  disposeRoute(routeId: number) {
    this.engine.sendMessage(
      JSON.stringify({
        type: "router",
        message: {
          event: "disposeRoute",
          routeId,
        },
      })
    );
  }

  didReceivedRouteData(data: any) {
    const event = data.event;
    if (event === "responseRoute") {
      this.responseRoute(data);
    } else if (event === "didPush") {
      this.didPush(data);
    } else if (event === "didReplace") {
      this.didReplace(data);
    } else if (event === "didPop") {
      this.didPop();
    }
  }

  didPush(message: any) {
    throw "native implementation";
  }

  didReplace(message: any) {
    throw "native implementation";
  }

  didPop() {
    throw "native implementation";
  }
}

export class BrowserRouter extends Router {
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
      const paramPath =
        name.indexOf("?") >= 0 ? name.substr(name.indexOf("?")) : "";
      if (searchParams.length > 0) {
        return `?route=${encodeURI(namePath)}${encodeURIComponent(
          paramPath
        )}&${searchParams.join("&")}`;
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
    window.history.pushState(
      { routeId },
      "",
      this.encodePath(name, message.params)
    );
    const scrollTop = window.pageYOffset;
    const nextPage = new Page(
      (this.engine.app as BrowserApp).rootElement,
      this.engine
    );
    this.pushHistory(nextPage, scrollTop);
  }

  didReplace(message: any) {
    const routeId = message.routeId;
    this.thePushingRouteId = routeId;
    const name = message.name;
    window.history.replaceState(
      { routeId },
      "",
      this.encodePath(name, message.params)
    );
    const nextPage = new Page(
      (this.engine.app as BrowserApp).rootElement,
      this.engine
    );
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

export class WXRouter extends Router {
  encodeRelativePath(name: string, params?: any): string {
    let searchParams: string[] = [];
    if (params) {
      for (const key in params) {
        searchParams.push(`${key}=${encodeURIComponent(params[key])}`);
      }
    }
    if (searchParams.length > 0) {
      return `${
        name.indexOf("/") === 0 ? name.substr(1) : name
      }?${searchParams.join("&")}`;
    } else {
      return `${name.indexOf("/") === 0 ? name.substr(1) : name}`;
    }
  }

  encodeIndexPath(name: string, params?: any): string {
    let searchParams: string[] = [];
    if (params) {
      for (const key in params) {
        searchParams.push(`${key}=${encodeURIComponent(params[key])}`);
      }
    }
    const namePath = name.indexOf("?") >= 0 ? name.split("?")[0] : name;
    const paramPath =
      name.indexOf("?") >= 0 ? name.substr(name.indexOf("?")) : "";
    if (searchParams.length > 0) {
      return `/${(this.engine.app as WXApp).indexPage}?route=${encodeURI(
        namePath
      )}${encodeURIComponent(paramPath)}&${searchParams.join("&")}`;
    } else {
      return `/${(this.engine.app as WXApp).indexPage}?route=${encodeURI(
        namePath
      )}${encodeURIComponent(paramPath)}`;
    }
  }

  didPush(message: any) {
    Router.beingPush = true;
    const routeId = message.routeId;
    this.thePushingRouteId = routeId;
    const name = message.name;
    MPEnv.platformScope.navigateTo({
      url: this.encodeRelativePath(name, message.params),
      fail: () => {
        MPEnv.platformScope.navigateTo({
          url: this.encodeIndexPath(name, message.params),
        });
      },
    });
    setTimeout(() => {
      Router.beingPush = false;
    }, 1000);
  }

  didReplace(message: any) {
    const routeId = message.routeId;
    this.thePushingRouteId = routeId;
    const name = message.name;
    MPEnv.platformScope.redirectTo({
      url: this.encodeRelativePath(name, message.params),
      fail: () => {
        MPEnv.platformScope.redirectTo({
          url: this.encodeIndexPath(name, message.params),
        });
      },
    });
  }

  didPop() {
    MPEnv.platformScope.navigateBack();
  }
}
