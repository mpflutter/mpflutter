declare var wx: any;

import { Engine } from "./engine";
import { MPEnv, PlatformType } from "./env";

export class WindowInfo {
  constructor(readonly engine: Engine) {}

  updateWindowInfo() {
    if (MPEnv.platformType === PlatformType.wxMiniProgram) {
      this.engine.sendMessage(
        JSON.stringify({
          type: "window_info",
          message: {
            window: {
              width: wx.getSystemInfoSync().screenWidth,
              height: wx.getSystemInfoSync().screenHeight,
              padding: {
                top: wx.getSystemInfoSync().statusBarHeight,
                bottom:
                  wx.getSystemInfoSync().screenHeight -
                  wx.getSystemInfoSync().safeArea.bottom,
              },
            },
            devicePixelRatio: wx.getSystemInfoSync().pixelRatio,
          },
        })
      );
    } else {
      this.engine.sendMessage(
        JSON.stringify({
          type: "window_info",
          message: {
            window: {
              width: document.body.clientWidth,
              height: window.innerHeight,
              padding: {
                top: 0,
                bottom: 0,
              },
            },
            devicePixelRatio: devicePixelRatio,
          },
        })
      );
    }
  }
}
