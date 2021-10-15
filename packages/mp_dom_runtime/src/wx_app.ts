declare var getCurrentPages: any;

import { Engine } from "./engine";
import { MPEnv } from "./env";
import { Page } from "./page";
import { Router } from "./router";
import { TextMeasurer } from "./text_measurer";
import EventEmitter from "eventemitter3";

export class WXApp {
  router: WXRouter = new WXRouter(this.engine);

  constructor(readonly indexPage: string, readonly engine: Engine) {
    engine.app = this;
  }
}

export const WXPage = (
  options: { route: string; params: any } | undefined,
  selector: string = "#vdom",
  app: WXApp = MPEnv.platformGlobal().app
) => {
  if (!(__MP_TARGET_WEAPP__ || __MP_TARGET_SWANAPP__)) return;
  return {
    onLoad(pageOptions: any) {
      const document = (this as any).selectComponent(selector).miniDom.document;
      (this as any).document = document;
      document.window = new EventEmitter();
      const documentTm = (this as any).selectComponent(selector + "_tm").miniDom.document;
      TextMeasurer.activeTextMeasureDocument = documentTm;
      Router.beingPush = false;
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

      (this as any).mpPage = new Page(document.body, app.engine, finalOptions, document);
      (this as any).mpPage.isFirst = getCurrentPages().length === 1;
    },
    onUnload() {
      if ((this as any).mpPage.viewId) {
        app.router.disposeRoute((this as any).mpPage.viewId);
      }
    },
    onShow() {
      TextMeasurer.activeTextMeasureDocument = (this as any).selectComponent(selector + "_tm").miniDom.document;
    },
    onPullDownRefresh() {
      (this as any).mpPage.onRefresh().then((it: any) => {
        MPEnv.platformScope.stopPullDownRefresh();
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
    onPageScroll(res: any) {
      (this as any).mpPage.onPageScroll(res.scrollTop);
      (this as any).document.window.scrollY = res.scrollTop;
      ((this as any).document.window as EventEmitter).emit("scroll", res.scrollTop);
    },
  };
};

class WXRouter extends Router {
  encodeRelativePath(name: string, params?: any): string {
    let searchParams: string[] = [];
    if (params) {
      for (const key in params) {
        searchParams.push(`${key}=${encodeURIComponent(params[key])}`);
      }
    }
    if (searchParams.length > 0) {
      return `${name.indexOf("/") === 0 ? name.substr(1) : name}?${searchParams.join("&")}`;
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
    const paramPath = name.indexOf("?") >= 0 ? name.substr(name.indexOf("?")) : "";
    if (searchParams.length > 0) {
      return `/${(this.engine.app as WXApp).indexPage}?route=${encodeURI(namePath)}${encodeURIComponent(
        paramPath
      )}&${searchParams.join("&")}`;
    } else {
      return `/${(this.engine.app as WXApp).indexPage}?route=${encodeURI(namePath)}${encodeURIComponent(paramPath)}`;
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
