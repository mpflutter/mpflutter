import { Engine, MPEnv } from "../..";
import { PlatformType } from "../../env";

export class WebPickers {
  static receivedWebPickersMessage(engine: Engine, message: any) {
    if (MPEnv.platformType === PlatformType.wxMiniProgram || MPEnv.platformType === PlatformType.swanMiniProgram) {
      this.wxMiniProgramReceivedWebPickersMessage(engine, message);
    } else {
      this.browserMiniProgramReceivedWebPickersMessage(engine, message);
    }
  }

  static wxMiniProgramReceivedWebPickersMessage(engine: Engine, message: any) {
    if (message["params"]["pickerType"] === "single") {
      (window as any).MPWebPicker.showSinglePicker({
        title: message["params"]["title"],
        itemList: message["params"]["items"],
        success: (res: any) => {
          engine.sendMessage(
            JSON.stringify({
              type: "action",
              message: {
                event: "callback",
                id: message["id"],
                data: res.tapIndex,
              },
            })
          );
        },
      });
    }
  }

  static browserMiniProgramReceivedWebPickersMessage(engine: Engine, message: any) {
    // if (!__MP_TARGET_BROWSER__) return;
    if (message["params"]["pickerType"] === "single") {
      (window as any).MPWebPicker.showSinglePicker({
        title: message["params"]["title"],
        itemList: message["params"]["items"],
        success: (res: any) => {
          engine.sendMessage(
            JSON.stringify({
              type: "action",
              message: {
                event: "callback",
                id: message["id"],
                data: res.tapIndex,
              },
            })
          );
        },
      });
    }
  }
}
