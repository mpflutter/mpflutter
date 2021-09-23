import { setDOMAttribute, setDOMStyle } from "../dom_utils";
import { MPPlatformView } from "./platform_view";

export class MPWebView extends MPPlatformView {
  elementType() {
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
