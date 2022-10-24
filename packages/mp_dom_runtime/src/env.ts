declare var wx: any;
declare var swan: any;
declare var tt: any;
declare var getApp: any;
declare var global: any;

export enum PlatformType {
  unknown,
  browser,
  wxMiniProgram,
  swanMiniProgram,
  ttMiniProgram,
}

let mpGlobal = {};

export const MPEnv = {
  platformType: (() => {
    if (typeof swan !== "undefined" && typeof swan.getSystemInfoSync === "function") {
      return PlatformType.swanMiniProgram;
    } else if (typeof tt !== "undefined" && typeof tt.getSystemInfoSync === "function") {
      return PlatformType.ttMiniProgram;
    } else if (typeof wx !== "undefined" && typeof wx.getSystemInfoSync === "function") {
      return PlatformType.wxMiniProgram;
    } else {
      return PlatformType.browser;
    }
  })(),
  platformScope: (() => {
    if (typeof swan !== "undefined" && typeof swan.getSystemInfoSync === "function") {
      return swan;
    } else if (typeof tt !== "undefined" && typeof tt.getSystemInfoSync === "function") {
      return tt;
    } else if (typeof wx !== "undefined" && typeof wx.getSystemInfoSync === "function") {
      return wx;
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
  platformPC: (): boolean => {
    if (__MP_TARGET_WEAPP__) {
      const platform = MPEnv.platformScope.getSystemInfoSync().platform;
      if (platform === "mac" || platform === "windows") {
        return true;
      }
    } else if (__MP_TARGET_BROWSER__) {
      return navigator?.maxTouchPoints === 1;
    }
    return false;
  },
  platformWindow: (document?: any): any | undefined => {
    if (document && document.window) {
      return document.window;
    } else if (typeof window !== "undefined") {
      return window;
    } else {
      return undefined;
    }
  },
  platformByteDance: (): boolean => {
    return typeof tt !== "undefined";
  },
};
