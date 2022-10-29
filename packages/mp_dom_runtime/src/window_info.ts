import { Engine } from "./engine";
import { MPEnv, PlatformType } from "./env";

export class WindowInfo {
  constructor(readonly engine: Engine) {}

  updateWindowInfo() {
    if (__MP_MINI_PROGRAM__) {
      const systemInfoSync = MPEnv.platformScope.getSystemInfoSync();
      this.engine.sendMessage(
        JSON.stringify({
          type: "window_info",
          message: {
            window: {
              width: systemInfoSync.screenWidth,
              height: (() => {
                if (MPEnv.platformByteDance()) {
                  return systemInfoSync.screenHeight - (systemInfoSync.safeArea?.top ?? 0) - 44;
                }
                return systemInfoSync.screenHeight;
              })(),
              padding: {
                top: systemInfoSync.statusBarHeight,
                bottom: systemInfoSync.screenHeight - systemInfoSync.safeArea?.bottom,
              },
            },
            devicePixelRatio: systemInfoSync.pixelRatio,
            darkMode: systemInfoSync.theme === "dark",
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
            darkMode:
              window.matchMedia("(prefers-color-scheme)").media !== "not all" &&
              window.matchMedia("(prefers-color-scheme: dark)").matches,
          },
        })
      );
    }
  }
}
