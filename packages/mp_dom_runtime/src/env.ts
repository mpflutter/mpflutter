declare var wx: any;
declare var swan: any;
declare var getApp: any;
declare var global: any;

export enum PlatformType {
  unknown,
  browser,
  wxMiniProgram,
  swanMiniProgram,
}

let mpGlobal = {};

export const MPEnv = {
  platformType: (() => {
    if (typeof wx !== "undefined" && typeof wx.getSystemInfoSync === "function") {
      return PlatformType.wxMiniProgram;
    } else if (typeof swan !== "undefined" && typeof swan.getSystemInfoSync === "function") {
      return PlatformType.swanMiniProgram;
    } else {
      return PlatformType.browser;
    }
  })(),
  platformScope: (() => {
    if (typeof wx !== "undefined" && typeof wx.getSystemInfoSync === "function") {
      return wx;
    } else if (typeof swan !== "undefined" && typeof swan.getSystemInfoSync === "function") {
      return swan;
    }
  })(),
  platformAppInstance: undefined,
  platformGlobal: (): any => {
    if (MPEnv.platformAppInstance) {
      return MPEnv.platformAppInstance;
    } else if (typeof getApp === "function") {
      return getApp();
    } else if (typeof window !== "undefined") {
      return window;
    } else if (typeof global !== "undefined") {
      return global;
    } else {
      return mpGlobal;
    }
  },
};
