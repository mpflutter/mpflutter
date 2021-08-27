import { ComponentView } from "../component_view";
import { setDOMAttribute } from "../dom_utils";
import { MPPlatformView } from "./platform_view";

export class MPVideoView extends MPPlatformView {
  elementType() {
    return "video";
  }

  setAttributes(attributes: any) {
    super.setAttributes(attributes);
    setDOMAttribute(this.htmlElement, "src", attributes.url);
    if (attributes.controls) {
      setDOMAttribute(this.htmlElement, "controls", attributes.controls);
    }
    if (attributes.autoplay) {
      setDOMAttribute(this.htmlElement, "autoplay", attributes.autoplay);
    }
    if (attributes.loop) {
      setDOMAttribute(this.htmlElement, "loop", attributes.loop);
    }
    if (attributes.muted) {
      setDOMAttribute(this.htmlElement, "muted", attributes.muted);
    }
    if (attributes.poster) {
      setDOMAttribute(this.htmlElement, "poster", attributes.poster);
    }
  }
}
