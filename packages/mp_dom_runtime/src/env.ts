declare var wx: any;
declare var swan: any;

export enum PlatformType {
  unknown,
  browser,
  wxMiniProgram,
  swanMiniProgram,
}

export const MPEnv = {
  platformType: (() => {
    if (
      typeof wx !== "undefined" &&
      typeof wx.getSystemInfoSync === "function"
    ) {
      return PlatformType.wxMiniProgram;
    } else if (
      typeof swan !== "undefined" &&
      typeof swan.getSystemInfoSync === "function"
    ) {
      return PlatformType.swanMiniProgram;
    } else {
      return PlatformType.browser;
    }
  })(),
  platformScope: (() => {
    if (
      typeof wx !== "undefined" &&
      typeof wx.getSystemInfoSync === "function"
    ) {
      return wx;
    } else if (
      typeof swan !== "undefined" &&
      typeof swan.getSystemInfoSync === "function"
    ) {
      return swan;
    }
  })(),
};
