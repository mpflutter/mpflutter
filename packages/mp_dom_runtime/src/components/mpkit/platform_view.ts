import { ComponentView } from "../component_view";

export class MPPlatformView extends ComponentView {
  private static _invokeMethodCompleter: { [key: string]: (result: any) => void } = {};

  static handleInvokeMethodCallback(seqId: string, result: any) {
    if (this._invokeMethodCompleter[seqId]) {
      this._invokeMethodCompleter[seqId](result);
      delete this._invokeMethodCompleter[seqId];
    }
  }

  classname = "PlatformView";

  elementType() {
    return "div";
  }

  setChildren(children: any) {
    super.setChildren(children);
    this.subviews.forEach((it) => {
      it.platformViewConstraints = {
        x: this.constraints?.x ?? 0.0,
        y: this.constraints?.y ?? 0.0,
      };
      it.updateLayout();
    });
  }

  onMethodCall(method: string, params: any) {}

  invokeMethod(method: string, params: any, requireResult: boolean = false): Promise<any> | undefined {
    let seqId = `${this.hashCode}_${Math.random()}`;
    this.engine.sendMessage(
      JSON.stringify({
        type: "platform_view",
        message: {
          event: "methodCall",
          hashCode: this.hashCode,
          method,
          params,
          seqId,
          requireResult,
        },
      })
    );
    if (requireResult) {
      return new Promise((res) => {
        MPPlatformView._invokeMethodCompleter[seqId] = res;
      });
    }
  }
}
