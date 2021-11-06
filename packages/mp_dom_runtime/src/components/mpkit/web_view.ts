import { MPEnv } from "../..";
import { PlatformType } from "../../env";
import { setDOMAttribute, setDOMStyle } from "../dom_utils";
import { MPPlatformView } from "./platform_view";

export class MPWebView extends MPPlatformView {
  elementType() {
    if (MPEnv.platformType === PlatformType.wxMiniProgram || MPEnv.platformType === PlatformType.swanMiniProgram) {
      return "wx-web-view";
    }
    return "iframe";
  }

  onMethodCall(method: string, params: any) {
    if (method === "reload") {
      setDOMAttribute(this.htmlElement, "src", "");
      setDOMAttribute(this.htmlElement, "src", this.attributes.url);
    } else if (method === "loadUrl" && params?.url) {
      setDOMAttribute(this.htmlElement, "src", "");
      setDOMAttribute(this.htmlElement, "src", params.url);
    }
  }

  setAttributes(attributes: any) {
    super.setAttributes(attributes);
    setDOMAttribute(this.htmlElement, "src", attributes.url);
    setDOMStyle(this.htmlElement, { border: "none" });
  }

  setChildren() {}
}
