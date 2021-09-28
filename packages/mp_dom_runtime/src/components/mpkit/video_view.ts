import { setDOMAttribute } from "../dom_utils";
import { MPPlatformView } from "./platform_view";

export class MPVideoView extends MPPlatformView {
  elementType() {
    return "video";
  }

  onMethodCall(method: string, params: any) {
    if (method === "play") {
      (this.htmlElement as HTMLMediaElement).play();
    } else if (method === "pause") {
      (this.htmlElement as HTMLMediaElement).pause();
    } else if (method === "setVolumn") {
      (this.htmlElement as HTMLMediaElement).muted = false;
      (this.htmlElement as HTMLMediaElement).volume = params.volumn;
    } else if (method === "volumnUp") {
      (this.htmlElement as HTMLMediaElement).muted = false;
      var volume = (this.htmlElement as HTMLMediaElement).volume;
      (this.htmlElement as HTMLMediaElement).volume = volume + 0.1;
    } else if (method === "volumnDown") {
      (this.htmlElement as HTMLMediaElement).muted = false;
      var volume = (this.htmlElement as HTMLMediaElement).volume;
      (this.htmlElement as HTMLMediaElement).volume = volume - 0.1;
    } else if (method === "setMuted") {
      (this.htmlElement as HTMLMediaElement).muted = params.muted;
    } else if (method === "fullscreen") {
      (this.htmlElement as HTMLMediaElement).requestFullscreen();
    } else if (method === "setPlaybackRate") {
      (this.htmlElement as HTMLMediaElement).playbackRate = params.playbackRate;
    } else if (method === "seekTo") {
      (this.htmlElement as HTMLMediaElement).currentTime = params.seekTo;
    } else if (method === "getCurrentTime") {
      return (this.htmlElement as HTMLVideoElement).currentTime;;
    }
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

  setChildren() {}
}
