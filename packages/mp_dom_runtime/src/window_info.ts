import { Engine } from "./engine";
import { MPEnv, PlatformType } from "./env";

export class WindowInfo {
  constructor(readonly engine: Engine) {}

  updateWindowInfo() {
    if (
      MPEnv.platformType === PlatformType.wxMiniProgram ||
      MPEnv.platformType === PlatformType.swanMiniProgram
    ) {
      this.engine.sendMessage(
        JSON.stringify({
          type: "window_info",
          message: {
            window: {
              width: MPEnv.platformScope.getSystemInfoSync().screenWidth,
              height: MPEnv.platformScope.getSystemInfoSync().screenHeight,
              padding: {
                top: MPEnv.platformScope.getSystemInfoSync().statusBarHeight,
                bottom:
                  MPEnv.platformScope.getSystemInfoSync().screenHeight -
                  MPEnv.platformScope.getSystemInfoSync().safeArea?.bottom,
              },
            },
            devicePixelRatio:
              MPEnv.platformScope.getSystemInfoSync().pixelRatio,
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
