import { MPEventChannel, MPMethodChannel } from "..";
import { Engine } from "../engine";
import { PluginRegister } from "./plugin_register";

export class PlatformChannelIO {
  private pluginInstances: { [key: string]: any } = {};

  responseCallbacks: { [key: number]: [(result: any) => void, (error: any) => void] } = {};

  constructor(readonly engine: Engine) {
    for (const key in PluginRegister.registedChannels) {
      if (Object.prototype.hasOwnProperty.call(PluginRegister.registedChannels, key)) {
        const clazz = PluginRegister.registedChannels[key];
        try {
          this.pluginInstances[key] = new clazz();
          this.pluginInstances[key].channelName = key;
          this.pluginInstances[key].engine = engine;
        } catch (error) {
          console.error(error);
        }
      }
    }
  }

  async didReceivedPlatformChannel(message: any) {
    if (message.event === "invokeMethod") {
      const method = message.method;
      const beInvokeMethod = message.beInvokeMethod;
      const beInvokeParams = message.beInvokeParams;
      const seqId = message.seqId;
      const instance = this.pluginInstances[method];
      if (instance instanceof MPMethodChannel) {
        try {
          const result = await instance.onMethodCall(beInvokeMethod, beInvokeParams);
          this.engine.sendMessage(
            JSON.stringify({
              type: "platform_channel",
              message: {
                event: "callbackResult",
                result: result,
                seqId: seqId,
              },
            })
          );
        } catch (error) {
          this.engine.sendMessage(
            JSON.stringify({
              type: "platform_channel",
              message: {
                event: "callbackResult",
                result: "ERROR:" + error,
                seqId: seqId,
              },
            })
          );
        }
      } else if (instance instanceof MPEventChannel) {
        if (beInvokeMethod === "listen") {
          instance.onListen(beInvokeParams, (data) => {
            this.engine.sendMessage(
              JSON.stringify({
                type: "platform_channel",
                message: {
                  event: "callbackEventSink",
                  method: method,
                  result: data,
                  seqId: seqId,
                },
              })
            );
          });
        } else if (beInvokeMethod === "cancel") {
          instance.onCancel(beInvokeParams);
        }
      }
    } else if (message.event === "callbackResult") {
      const seqId = message.seqId;
      const result = message.result;
      const callback = this.responseCallbacks[seqId];
      if (callback !== undefined) {
        if (result === "NOTIMPLEMENTED" || (typeof result === "string" && result.indexOf("ERROR:") === 0)) {
          callback[1](result);
        } else {
          callback[0](result);
        }
      }
      delete this.responseCallbacks[seqId];
    }
  }
}
