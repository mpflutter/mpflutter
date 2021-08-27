declare var global: any;

let self = window ?? global;

export class MethodChannelHandler {
  static installHandler() {
    (self as any).mp_core_methodChannelHandlerWebOnly = this.handler;
  }

  static async handler(
    method: string,
    beInvokeMethod: string,
    beInvokeParams: any,
    resultCallback: (jsonEncodedResult: string) => void
  ) {
    if (!Object.prototype.hasOwnProperty.call(self, method)) {
      resultCallback("NOTIMPLEMENTED");
      return;
    }
    if (!(typeof (self as any)[method][beInvokeMethod] === "function")) {
      resultCallback("NOTIMPLEMENTED");
      return;
    }
    try {
      let result = await (self as any)[method][beInvokeMethod](beInvokeParams);
      resultCallback(JSON.stringify(result));
    } catch (error) {
      resultCallback("ERROR:" + error);
    }
  }
}
