declare var wx: any;
declare var swan: any;

import { Engine } from "../../engine";
import { MPEnv, PlatformType } from "../../env";

export class WebDialogs {
  static receivedWebDialogsMessage(engine: Engine, message: any) {
    if (__MP_MINI_PROGRAM__) {
      this.wxMiniProgramReceivedWebDialogsMessage(engine, message);
    } else {
      this.browserMiniProgramReceivedWebDialogsMessage(engine, message);
    }
  }

  static wxMiniProgramReceivedWebDialogsMessage(engine: Engine, message: any) {
    if (!__MP_MINI_PROGRAM__) return;
    if (message["params"]["dialogType"] === "alert") {
      MPEnv.platformScope.showModal({
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
      MPEnv.platformScope.showModal({
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
      if (__MP_TARGET_SWANAPP__) {
        MPEnv.platformScope.openReplyEditor({
          contentPlaceholder: message["params"]["message"],
          content: message["params"]["defaultValue"] ?? "",
          sendText: "确认",
          success: (res: any) => {
            swan.closeReplyEditor();
            if (res.status === "reply") {
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
            } else {
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
            }
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
      } else {
        if (MPEnv.platformByteDance() && MPEnv.platformScope.showPrompt) {
          MPEnv.platformScope.showPrompt({
            title: message["params"]["message"],
            success: (res: any) => {
              if (res.confirm) {
                engine.sendMessage(
                  JSON.stringify({
                    type: "action",
                    message: {
                      event: "callback",
                      id: message["id"],
                      data: res.inputValue,
                    },
                  })
                );
              } else {
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
              }
            },
          });
          return;
        }
        MPEnv.platformScope.showModal({
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
      }
    } else if (message["params"]["dialogType"] === "actionSheet") {
      MPEnv.platformScope.showActionSheet({
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
      MPEnv.platformScope.showToast(params);
    } else if (message["params"]["dialogType"] === "hideToast") {
      MPEnv.platformScope.hideToast();
    }
  }

  static browserMiniProgramReceivedWebDialogsMessage(engine: Engine, message: any) {
    if (!__MP_TARGET_BROWSER__) return;
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
      const result = window.prompt(message["params"]["message"], message["params"]["defaultValue"] ?? "");
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
    } else if (message["params"]["dialogType"] === "picker") {
      (window as any).MPWebDialog.showPicker({
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
