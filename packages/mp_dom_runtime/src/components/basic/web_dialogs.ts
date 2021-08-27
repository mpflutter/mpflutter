declare var wx: any;

import { Engine } from "../../engine";
import { MPEnv, PlatformType } from "../../env";

export class WebDialogs {
  static receivedWebDialogsMessage(engine: Engine, message: any) {
    if (MPEnv.platformType === PlatformType.wxMiniProgram) {
      this.wxMiniProgramReceivedWebDialogsMessage(engine, message);
    } else {
      this.browserMiniProgramReceivedWebDialogsMessage(engine, message);
    }
  }

  static wxMiniProgramReceivedWebDialogsMessage(engine: Engine, message: any) {
    if (message["params"]["dialogType"] === "alert") {
      wx.showModal({
        content: message["params"]["message"],
        showCancel: false,
        confirmText: "确定",
        success: () => {
          engine.sendMessage(
            JSON.stringify({
              type: "action",
              message: { event: "callback", id: message["id"] },
            })
          );
        },
      });
    } else if (message["params"]["dialogType"] === "confirm") {
      wx.showModal({
        content: message["params"]["message"],
        cancelText: "取消",
        confirmText: "确认",
        success: (res: any) => {
          engine.sendMessage(
            JSON.stringify({
              type: "action",
              message: {
                event: "callback",
                id: message["id"],
                data: res.confirm == true,
              },
            })
          );
        },
      });
    } else if (message["params"]["dialogType"] === "prompt") {
      wx.showModal({
        title: message["params"]["message"],
        content: message["params"]["defaultValue"] ?? "",
        editable: true,
        cancelText: "取消",
        confirmText: "确认",
        success: (res: any) => {
          engine.sendMessage(
            JSON.stringify({
              type: "action",
              message: {
                event: "callback",
                id: message["id"],
                data: res.content,
              },
            })
          );
        },
      });
    } else if (message["params"]["dialogType"] === "actionSheet") {
      wx.showActionSheet({
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
        fail: () => {
          engine.sendMessage(
            JSON.stringify({
              type: "action",
              message: {
                event: "callback",
                id: message["id"],
                data: null,
              },
            })
          );
        },
      });
    } else if (message["params"]["dialogType"] === "showToast") {
      let params: any = {};
      if (message["params"]["title"]) {
        params.title = message["params"]["title"];
      }
      if (message["params"]["icon"]) {
        params.icon = message["params"]["icon"]?.replace("ToastIcon.", "");
      }
      if (message["params"]["duration"]) {
        params.duration = message["params"]["duration"];
      }
      if (message["params"]["mask"]) {
        params.mask = message["params"]["mask"];
      }
      wx.showToast(params);
    } else if (message["params"]["dialogType"] === "hideToast") {
      wx.hideToast();
    }
  }

  static browserMiniProgramReceivedWebDialogsMessage(
    engine: Engine,
    message: any
  ) {
    if (message["params"]["dialogType"] === "alert") {
      window.alert(message["params"]["message"]);
      engine.sendMessage(
        JSON.stringify({
          type: "action",
          message: { event: "callback", id: message["id"] },
        })
      );
    } else if (message["params"]["dialogType"] === "confirm") {
      const result = window.confirm(message["params"]["message"]);
      engine.sendMessage(
        JSON.stringify({
          type: "action",
          message: { event: "callback", id: message["id"], data: result },
        })
      );
    } else if (message["params"]["dialogType"] === "prompt") {
      const result = window.prompt(
        message["params"]["message"],
        message["params"]["defaultValue"] ?? ""
      );
      engine.sendMessage(
        JSON.stringify({
          type: "action",
          message: { event: "callback", id: message["id"], data: result },
        })
      );
    } else if (message["params"]["dialogType"] === "actionSheet") {
      (window as any).MPWebDialog.showActionSheet({
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
        fail: () => {
          engine.sendMessage(
            JSON.stringify({
              type: "action",
              message: {
                event: "callback",
                id: message["id"],
                data: null,
              },
            })
          );
        },
      });
    } else if (message["params"]["dialogType"] === "showToast") {
      let params: any = {};
      if (message["params"]["title"]) {
        params.title = message["params"]["title"];
      }
      if (message["params"]["icon"]) {
        params.icon = message["params"]["icon"]?.replace("ToastIcon.", "");
      }
      if (message["params"]["duration"]) {
        params.duration = message["params"]["duration"];
      }
      if (message["params"]["mask"]) {
        params.mask = message["params"]["mask"];
      }
      (window as any).MPWebDialog.showToast(params);
    } else if (message["params"]["dialogType"] === "hideToast") {
      (window as any).MPWebDialog.hideToast();
    }
  }
}
