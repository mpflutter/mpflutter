import { ComponentView } from "../component_view";

export class MPPlatformView extends ComponentView {
  elementType() {
    return "div";
  }

  onMethodCall(method: string, params: any) {}

  invokeMethod(method: string, params: string) {
    this.engine.sendMessage(
      JSON.stringify({
        type: "platform_view",
        message: {
          event: "methodCall",
          hashCode: this.hashCode,
          method,
          params,
        },
      })
    );
  }
}
