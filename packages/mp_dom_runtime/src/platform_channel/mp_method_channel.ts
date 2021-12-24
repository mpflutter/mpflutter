import { Engine } from "../engine";

let seqId = 0;

function generateSeqId() {
  seqId++;
  return seqId;
}

export class MPMethodChannel {
  channelName?: string;
  engine?: Engine;

  onMethodCall(method: string, params: any): Promise<any> | any {
    throw "NOTIMPLEMENTED";
  }

  async invokeMethod(method: string, params: any) {
    return new Promise((res, rej) => {
      if (this.channelName && this.engine) {
        const seqId = generateSeqId();
        this.engine.sendMessage(
          JSON.stringify({
            type: "platform_channel",
            message: {
              event: "invokeMethod",
              method: this.channelName,
              beInvokeMethod: method,
              beInvokeParams: params,
              seqId,
            },
          })
        );
        this.engine.platformChannelIO.responseCallbacks[seqId] = [res, rej];
      }
    });
  }
}
