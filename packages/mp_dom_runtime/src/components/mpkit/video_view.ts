import { MPEnv, PlatformType } from "../../env";
import { setDOMAttribute } from "../dom_utils";
import { MPPlatformView } from "./platform_view";

export class MPVideoView extends MPPlatformView {
  videoContext: any;
  id: string;

  constructor(readonly document: Document, readonly initialAttributes?: any) {
    super(document, initialAttributes);
    this.id = "video_" + Math.random().toString();
    this.htmlElement.setAttribute("id", this.id);
  }

  elementType() {
    return "video";
  }

  async onMethodCall(method: string, params: any) {
    if (__MP_TARGET_BROWSER__) {
      this.onBrowserMethodCall(method, params);
    } else if (__MP_MINI_PROGRAM__) {
      if (!this.videoContext) {
        if (MPEnv.platformByteDance()) {
          this.videoContext = MPEnv.platformScope.createVideoContext(this.id);
        } else {
          this.videoContext = await (this.htmlElement as any).$$getContext();
        }
      }
      if (this.videoContext) {
        this.onMiniProgramMethodCall(method, params);
      }
    }
  }

  onBrowserMethodCall(method: string, params: any) {
    if (!__MP_TARGET_BROWSER__) return;
    if (method === "play") {
      (this.htmlElement as HTMLMediaElement).play();
    } else if (method === "pause") {
      (this.htmlElement as HTMLMediaElement).pause();
    } else if (method === "setVolume") {
      if (MPEnv.platformByteDance()) {
        this.videoContext.setMediaVolume({ value: params.volume });
        return;
      }
      (this.htmlElement as HTMLMediaElement).muted = false;
      (this.htmlElement as HTMLMediaElement).volume = params.volume;
    } else if (method === "volumeUp") {
      if (MPEnv.platformByteDance()) {
        this.videoContext.getMediaVolume({
          success: (res: any) => {
            this.videoContext.setMediaVolume({ value: res.value + 0.1 });
          },
        });
        return;
      }
      (this.htmlElement as HTMLMediaElement).muted = false;
      var volume = (this.htmlElement as HTMLMediaElement).volume;
      (this.htmlElement as HTMLMediaElement).volume = volume + 0.1;
    } else if (method === "volumeDown") {
      if (MPEnv.platformByteDance()) {
        this.videoContext.getMediaVolume({
          success: (res: any) => {
            this.videoContext.setMediaVolume({ value: res.value - 0.1 });
          },
        });
        return;
      }
      (this.htmlElement as HTMLMediaElement).muted = false;
      var volume = (this.htmlElement as HTMLMediaElement).volume;
      (this.htmlElement as HTMLMediaElement).volume = volume - 0.1;
    } else if (method === "setMuted") {
      if (MPEnv.platformByteDance()) {
        this.videoContext.setMediaVolume({ value: params.muted ? 0.0 : 0.5 });
        return;
      }
      (this.htmlElement as HTMLMediaElement).muted = params.muted;
    } else if (method === "fullscreen") {
      (this.htmlElement as HTMLMediaElement).requestFullscreen();
    } else if (method === "setPlaybackRate") {
      (this.htmlElement as HTMLMediaElement).playbackRate = params.playbackRate;
    } else if (method === "seekTo") {
      (this.htmlElement as HTMLMediaElement).currentTime = params.seekTo;
    } else if (method === "getCurrentTime") {
      return (this.htmlElement as HTMLVideoElement).currentTime;
    }
  }

  onMiniProgramMethodCall(method: string, params: any) {
    if (!__MP_MINI_PROGRAM__) return;
    if (method === "play") {
      this.videoContext.play();
    } else if (method === "pause") {
      this.videoContext.pause();
    } else if (method === "setVolume") {
      // todo
    } else if (method === "volumeUp") {
      // todo
    } else if (method === "volumeDown") {
      // todo
    } else if (method === "setMuted") {
      this.videoContext.muted = params.muted;
    } else if (method === "fullscreen") {
      this.videoContext.requestFullScreen();
    } else if (method === "setPlaybackRate") {
      this.videoContext.playbackRate(params.playbackRate);
    } else if (method === "seekTo") {
      this.videoContext.seek(params.seekTo);
    } else if (method === "getCurrentTime") {
      // todo
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
