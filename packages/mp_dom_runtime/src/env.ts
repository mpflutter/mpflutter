declare var wx: any;

export enum PlatformType {
  unknown,
  browser,
  wxMiniProgram,
}

export const MPEnv = {
  platformType: (() => {
    if (
      typeof wx !== "undefined" &&
      typeof wx.getSystemInfoSync === "function"
    ) {
      return PlatformType.wxMiniProgram;
    } else {
      return PlatformType.browser;
    }
  })(),
};
