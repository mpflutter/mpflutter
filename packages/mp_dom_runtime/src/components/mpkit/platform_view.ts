import { ComponentView } from "../component_view";

export class MPPlatformView extends ComponentView {

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
