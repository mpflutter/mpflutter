import { MPEnv } from "../env";

export class MethodChannelHandler {
  static installHandler() {
    MPEnv.platformGlobal().mp_core_methodChannelHandlerWebOnly = this.handler;
  }

  static async handler(
    method: string,
    beInvokeMethod: string,
    beInvokeParams: any,
    resultCallback: (jsonEncodedResult: string) => void,
    eventSink?: (data: string) => void
  ) {
    if (!Object.prototype.hasOwnProperty.call(MPEnv.platformGlobal(), method)) {
      resultCallback("NOTIMPLEMENTED");
      return;
    }
    if (!(typeof MPEnv.platformGlobal()[method][beInvokeMethod] === "function")) {
      resultCallback("NOTIMPLEMENTED");
      return;
    }
    try {
      let result = await MPEnv.platformGlobal()[method][beInvokeMethod](beInvokeParams, eventSink);
      resultCallback(JSON.stringify(result));
    } catch (error) {
      resultCallback("ERROR:" + error);
    }
  }
}
