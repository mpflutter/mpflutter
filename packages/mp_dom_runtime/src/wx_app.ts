declare var getCurrentPages: any;
declare var require: any;
declare var tt: any;

import { PluginRegister } from "./platform_channel/plugin_register";
import { MPMethodChannel } from "./platform_channel/mp_method_channel";
import { Engine } from "./engine";
import { MPEnv } from "./env";
import { Page } from "./page";
import { Router } from "./router";
import { TextMeasurer } from "./text_measurer";

let usingComponentsConfig = {};
try {
  const indexJSON = require("mp-custom-components");
  if (indexJSON.usingComponents) {
    usingComponentsConfig = indexJSON.usingComponents;
  }
} catch (error) {
  console.error(error);
}

const kboneConfig = {
  router: {},
  runtime: {
    subpackagesMap: {},
    tabBarMap: {},
    usingComponents: usingComponentsConfig,
  },
  pages: {
    index: {},
  },
  redirect: {},
  optimization: {
    domSubTreeLevel: 10,
    elementMultiplexing: true,
    textMultiplexing: true,
    commentMultiplexing: true,
    domExtendMultiplexing: true,
    styleValueReduce: 5000,
    attrValueReduce: 5000,
  },
};

export class WXApp {
  router: WXRouter = new WXRouter(this.engine);

  constructor(readonly indexPage: string, readonly engine: Engine) {
    engine.app = this;
  }
}

export const WXPage = function (
  options: { route: string; params: any } | undefined,
  selector: string = "#vdom",
  app: WXApp = MPEnv.platformGlobal().app
) {
  if (!__MP_MINI_PROGRAM__) return;
  return {
    data: {
      pageMeta: {
        naviBar: {},
      },
    },
    kboneRender: undefined as any,
    kboneDocument: undefined as any,
    kbonePageId: undefined as any,
    lightModeStyle: {
      naviBarBackgroundColor: "#ffffff",
      naviBarFrontColor: "#000000",
    },
    darkModeStyle: {
      naviBarBackgroundColor: "#000000",
      naviBarFrontColor: "#ffffff",
    },
    prepare() {
      const mpRes = this.kboneRender.createPage((this as any).route, kboneConfig);
      this.kbonePageId = mpRes.pageId;
      const window = mpRes.window;
      this.kboneDocument = mpRes.document;
      this.kboneDocument.window = window;

      window.$$createSelectorQuery = () => MPEnv.platformScope.createSelectorQuery().in(this);
      window.$$createIntersectionObserver = (options: any) =>
        MPEnv.platformScope.createIntersectionObserver(this, options);
      const themeStyle =
        MPEnv.platformScope.getSystemInfoSync().theme === "dark" ? this.darkModeStyle : this.lightModeStyle;
      (this as any).setData({
        pageId: this.kbonePageId,
        "pageMeta.naviBar.backgroundColor": themeStyle.naviBarBackgroundColor,
        "pageMeta.naviBar.naviBarFrontColor": themeStyle.naviBarFrontColor,
      });
    },
    onLoad(pageOptions: any) {
      this.prepare();
      const document = this.kboneDocument;
      const documentTm = this.kboneDocument;
      TextMeasurer.activeTextMeasureDocument = documentTm;
      Router.clearBeingPushTimeout();
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
            route: (this as any).route?.replace(basePath, "") ?? "/",
            params: params,
          };
          if (finalOptions.route === "/index") {
            finalOptions.route = "/";
          }
        }
      }
      if (finalOptions?.route) {
        finalOptions.route = decodeURIComponent(finalOptions.route);
        finalOptions.params = { ...pageOptions };
      }

      (this as any).mpPage = new Page(document.body, app.engine, finalOptions, document);
      (this as any).mpPage.miniProgramPage = this;
      (this as any).mpPage.isFirst = getCurrentPages().length === 1;
    },
    onUnload() {
      if ((this as any).mpPage.viewId) {
        app.router.disposeRoute((this as any).mpPage.viewId);
      }
    },
    onShow() {
      TextMeasurer.activeTextMeasureDocument =
        this.kboneDocument ?? (this as any).selectComponent(selector + "_tm").miniDom.document;
      Router.clearBeingPushTimeout();
      Router.beingPush = false;
      if (__MP_TARGET_WEAPP__) {
        MPEnv.platformScope.onAppShow(this.onAppShow.bind(this));
        const title = (this as any).data?.pageMeta?.naviBar?.title;
        if (title) {
          MPEnv.platformScope.setNavigationBarTitle({ title: title });
        }
      }
    },
    onHide() {
      if (__MP_TARGET_WEAPP__) {
        MPEnv.platformScope.offAppShow(this.onAppShow);
      }
    },
    onAppShow() {
      if (__MP_TARGET_WEAPP__) {
        const title = (this as any).data?.pageMeta?.naviBar?.title;
        if (title) {
          MPEnv.platformScope.setNavigationBarTitle({ title: title });
        }
      }
    },
    onPullDownRefresh() {
      (this as any).mpPage.onRefresh().then((it: any) => {
        MPEnv.platformScope.stopPullDownRefresh();
      });
    },
    onShareAppMessage(info: any) {
      return {
        promise: (this as any).mpPage.onWechatMiniProgramShareAppMessage(info),
      };
    },
    onShareTimeline() {
      return (this as any).mpPage.onWechatMiniProgramShareTimeline();
    },
    onAddToFavorites(info: any) {
      return (this as any).mpPage.onWechatMiniProgramAddToFavorites();
    },
    onReachBottom() {
      (this as any).mpPage.onReachBottom();
    },
    onPageScroll(res: any) {
      (this as any).mpPage.onPageScroll(res.scrollTop);
      this.kboneDocument.window.scrollY = res.scrollTop;
      this.kboneDocument.window.scrollY = res.scrollTop;
      this.kboneDocument.window.scrollY = res.scrollTop;
      this.kboneDocument.window.$$trigger("scroll", res.scrollTop);
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
      return `${name}?${searchParams.join("&")}`;
    } else {
      return `${name}`;
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
    Router.clearBeingPushTimeout();
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
    Router.beingPushTimeout = setTimeout(() => {
      Router.beingPush = false;
    }, 1000);
  }

  didReplace(message: any) {
    Router.clearBeingPushTimeout();
    Router.beingPush = true;
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
    Router.beingPushTimeout = setTimeout(() => {
      Router.beingPush = false;
    }, 1000);
  }

  async didPop() {
    if (Router.beingPush) {
      await this.delayPop();
    }
    Router.clearBeingPushTimeout();
    Router.beingPush = true;
    MPEnv.platformScope.navigateBack();
    Router.beingPushTimeout = setTimeout(() => {
      Router.beingPush = false;
    }, 1000);
  }

  delayPop() {
    if (
      __MP_TARGET_WEAPP__ &&
      (MPEnv.platformScope.getSystemInfoSync().platform === "ios" ||
        MPEnv.platformScope.getSystemInfoSync().platform === "windows" ||
        MPEnv.platformScope.getSystemInfoSync().platform === "mac")
    ) {
      return new Promise((res) => {
        setTimeout(() => {
          res(null);
        }, 500);
      });
    }
  }
}

class FlutterPlatformChannel extends MPMethodChannel {
  async onMethodCall(method: string, params: any) {
    if (method === "Clipboard.setData") {
      MPEnv.platformScope.setClipboardData({ data: params.text });
      return null;
    } else if (method === "Clipboard.getData") {
      return new Promise((res, rej) => {
        MPEnv.platformScope.getClipboardData({
          success: (result: any) => {
            res({ text: result.data });
          },
          fail: (e: any) => {
            rej(e);
          },
        });
      });
    } else if (method === "RootBundle.getAssets") {
      if (this.engine?.debugger) {
        const assetUrl = (() => {
          return `http://${this.engine.debugger.serverAddr}/assets/${params.uri}`;
        })();
        return new Promise((resolver, rejector) => {
          MPEnv.platformScope.request({
            url: assetUrl,
            responseType: "arraybuffer",
            success: (res: any) => {
              resolver(MPEnv.platformScope.arrayBufferToBase64(res.data as ArrayBuffer));
            },
            fail: (e: any) => {
              rejector(e.errMsg);
            },
          });
        });
      } else {
        return MPEnv.platformScope.getFileSystemManager().readFileSync("assets/" + params.uri, "base64", 0);
      }
    } else {
      throw "NOTIMPLEMENTED";
    }
  }
}

PluginRegister.registerChannel("flutter/platform", FlutterPlatformChannel);
