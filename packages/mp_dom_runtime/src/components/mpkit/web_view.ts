import { MPEnv } from "../..";
import { PlatformType } from "../../env";
import { setDOMAttribute, setDOMStyle } from "../dom_utils";
import { MPPlatformView } from "./platform_view";

export class MPWebView extends MPPlatformView {
  constructor(readonly document: Document, readonly initialAttributes?: any) {
    super(document, initialAttributes);
    if (__MP_MINI_PROGRAM__) {
      this.htmlElement.addEventListener("message", (e: any) => {
        if (e?.detail?.data instanceof Array) {
          this.invokeMethod("mini_program_message", { data: e.detail.data });
        }
      });
    }
  }

  elementType() {
    if (__MP_MINI_PROGRAM__) {
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
