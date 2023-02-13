declare var require: any;
declare var wx: any;
declare var tt: any;
declare var swan: any;

import { BrowserApp } from "./browser_app";
import { WXApp } from "./wx_app";
import { CustomPaint, MPDrawable } from "./components/basic/custom_paint";
import { WebDialogs } from "./components/basic/web_dialogs";
import { ComponentFactory } from "./components/component_factory";
import { MPPlatformView } from "./components/mpkit/platform_view";
import { MPScaffold } from "./components/mpkit/scaffold";
import { createDebugger, Debugger } from "./debugger/debugger";
import { MPEnv } from "./env";
import { PlatformChannelIO } from "./platform_channel/platform_channel_io";
import { MPJS } from "./mpjs/mpjs";
import { Page } from "./page";
import { Router } from "./router";
import { TextMeasurer } from "./text_measurer";
import { WindowInfo } from "./window_info";
import { wrapDartObject } from "./components/dart_object";
import { CollectionView } from "./components/basic/collection_view";
import { EditableText } from "./components/basic/editable_text";

export class Engine {
  private started: boolean = false;
  private codeBlock?: () => void;
  debugger?: Debugger;
  private messageQueue: string[] = [];
  drawable: MPDrawable;
  componentFactory: ComponentFactory;
  managedViews: { [key: number]: Page } = {};
  unmanagedViewFrameData: { [key: number]: any[] } = {};
  mpJS: MPJS = new MPJS(this);
  app?: BrowserApp | WXApp;
  router?: Router;
  windowInfo = new WindowInfo(this);
  pageMode: boolean = false;
  platformChannelIO: PlatformChannelIO;

  constructor() {
    this.componentFactory = new ComponentFactory(this);
    this.drawable = new MPDrawable(this);
    this.platformChannelIO = new PlatformChannelIO(this);
    this.installWeChatComponentContextGetter();
  }

  private installWeChatComponentContextGetter() {
    if (__MP_MINI_PROGRAM__) {
      MPEnv.platformGlobal().mp_core_weChatComponentContextGetter = async (hashCode: number) => {
        const target = this.componentFactory.cachedView[hashCode];
        if (target) {
          const ctx = await (target.htmlElement as any).$$getContext();
          return ctx;
        }
      };
    }
  }

  public static codeBlockWithCodePath(codePath: string): Promise<() => void> {
    return new Promise((res, rej) => {
      const httpRequest = new XMLHttpRequest();
      httpRequest.onload = () => {
        res(() => {
          eval(httpRequest.response);
        });
      };
      httpRequest.onerror = (error) => {
        rej(error);
      };
      httpRequest.open("GET", codePath);
      httpRequest.send();
    });
  }

  public static codeBlockWithFile(filePath: string): () => void {
    return () => {
      require(filePath).main();
    };
  }

  public static registerPlatformView(viewType: string, viewClass: typeof MPPlatformView) {
    ComponentFactory.components[viewType] = viewClass;
  }

  public initWithDebuggerServerAddr(debuggerServerAddr: string) {
    this.debugger = createDebugger(debuggerServerAddr, this);
  }

  public initWithCodeBlock(codeBlock: () => void) {
    this.codeBlock = codeBlock;
  }

  public start() {
    if (this.started) return;
    if (!this.codeBlock && !this.debugger) return;
    this.windowInfo.updateWindowInfo();
    this.listenViewport();
    MPEnv.platformGlobal();
    if (__MP_TARGET_BROWSER__) {
      MPEnv.platformGlobal().engineScope = this.mpJS.engineScope;
    } else {
      MPEnv.platformGlobal().JSON = JSON;
      MPEnv.platformGlobal().setTimeout = function (a: any, b: any) {
        var ret = setTimeout(a, b);
        return parseInt(ret as any);
      };
      MPEnv.platformGlobal().setInterval = function (a: any, b: any) {
        var ret = setInterval(a, b);
        return parseInt(ret as any);
      };
      MPEnv.platformGlobal().clearTimeout = function (v: any) {
        clearTimeout(v);
      };
      MPEnv.platformGlobal().clearInterval = function (v: any) {
        clearInterval(v);
      };
      MPEnv.platformGlobal().engineScope = this.mpJS.engineScope;
      MPEnv.platformGlobal().Object = Object;
      if (typeof wx !== "undefined") {
        MPEnv.platformGlobal().wx = wx;
        MPEnv.platformGlobal().uni = wx;
      }
      if (typeof swan !== "undefined") {
        MPEnv.platformGlobal().swan = swan;
        MPEnv.platformGlobal().uni = swan;
      }
      if (typeof tt !== "undefined") {
        MPEnv.platformGlobal().tt = tt;
        MPEnv.platformGlobal().uni = tt;
      }
    }
    if (this.debugger) {
      this.debugger.didConnectCallback = () => {
        this.windowInfo.updateWindowInfo();
      };
      this.debugger.start();
    }
    if (this.codeBlock) {
      this.mpJS.engineScope.onMessage = (message: string) => {
        this.didReceivedMessage(message);
      };
      this.mpJS.engineScope.onMapMessage = (message: any) => {
        this.didReceivedMessage(message, true);
      };
      (() => {
        this.codeBlock();
      })();
    }
    this.started = true;
  }

  sendMessage(message: string) {
    if (MPEnv.platformGlobal()?.mpDEBUG) {
      console.log(new Date().getTime(), "out", JSON.parse(message));
    }
    if (this.debugger) {
      this.debugger.sendMessage(message);
    } else {
      if (this.mpJS.engineScope.postMessage) {
        this.mpJS.engineScope.postMessage(message);
      } else {
        this.messageQueue.push(message);
      }
    }
  }

  flushQueueMessage() {
    if (this.debugger) {
      return;
    } else {
      if (this.mpJS.engineScope.postMessage) {
        this.messageQueue.forEach((it) => {
          this.mpJS.engineScope.postMessage(it);
        });
      }
    }
  }

  didReceivedMessage(message: string, isDartObject: boolean = false) {
    let decodedMessage = isDartObject ? wrapDartObject(message) : JSON.parse(message);
    if (!decodedMessage) return;
    if (MPEnv.platformGlobal()?.mpDEBUG) {
      console.log(new Date().getTime(), "in", decodedMessage);
    }
    if (decodedMessage.type === "ready") {
      this.flushQueueMessage();
    } else if (decodedMessage.type === "frame_data") {
      this.didReceivedFrameData(decodedMessage.message);
    } else if (decodedMessage.type === "diff_data") {
      this.didReceivedDiffData(decodedMessage.message);
    } else if (decodedMessage.type === "element_gc") {
      if (decodedMessage.message instanceof Array) {
        this.didReceivedElementGC(decodedMessage.message);
      }
    } else if (decodedMessage.type === "decode_drawable") {
      this.drawable.decodeDrawable(decodedMessage.message);
    } else if (decodedMessage.type === "custom_paint") {
      CustomPaint.didReceivedCustomPaintMessage(decodedMessage.message, this);
    } else if (decodedMessage.type === "route") {
      (this.app?.router ?? this.router)?.didReceivedRouteData(decodedMessage.message);
    } else if (decodedMessage.type === "mpjs") {
      this.didReceivedMPJS(decodedMessage);
    } else if (decodedMessage.type === "action:web_dialogs") {
      WebDialogs.receivedWebDialogsMessage(this, decodedMessage.message);
    } else if (decodedMessage.type === "scaffold") {
      this.didReceivedScaffold(decodedMessage.message);
    } else if (decodedMessage.type === "scroll_view") {
      this.didReceivedScrollView(decodedMessage.message);
    } else if (decodedMessage.type === "editable_text") {
      this.didReceivedEditableText(decodedMessage.message);
    } else if (decodedMessage.type === "rich_text" && decodedMessage.message?.event === "doMeasure") {
      TextMeasurer.didReceivedDoMeasureData(this, decodedMessage.message);
    } else if (decodedMessage.type === "rich_text" && decodedMessage.message?.event === "doMeasureTextPainter") {
      TextMeasurer.didReceivedDoMeasureTextPainter(this, decodedMessage.message);
    } else if (decodedMessage.type === "platform_view") {
      this.didReceivedPlatformView(decodedMessage.message);
    } else if (decodedMessage.type === "platform_channel") {
      this.platformChannelIO.didReceivedPlatformChannel(decodedMessage.message);
    }
  }

  didReceivedFrameData(frameData: { [key: string]: any }) {
    if (!frameData) return;
    const routeId = frameData.routeId;
    if (this.managedViews[routeId] === undefined) {
      if (!this.unmanagedViewFrameData[routeId]) {
        this.unmanagedViewFrameData[routeId] = [];
      }
      this.unmanagedViewFrameData[routeId].push(frameData);
      return;
    }
    if (typeof routeId === "number") {
      this.managedViews[routeId]?.didReceivedFrameData(frameData);
    }
  }

  didReceivedDiffData(frameData: { [key: string]: any }) {
    if (!frameData) return;
    (frameData.diffs as any[]).forEach((it) => {
      this.componentFactory.create(it, undefined!);
      this.componentFactory.createAncestors(it, undefined!);
    });
  }

  didReceivedElementGC(elements: number[]) {
    elements.forEach((it) => {
      this.componentFactory.cachedView[it]?.dispose();
      delete this.componentFactory.cachedElement[it];
      delete this.componentFactory.cachedView[it];
    });
  }

  didReceivedScaffold(message: any) {
    if (message.event === "onRefreshEnd") {
      let target = this.componentFactory.cachedView[message.target] as MPScaffold;
      if (target) {
        target.refreshEndResolver?.(undefined);
        target.refreshEndResolver = undefined;
      }
    } else if (message.event === "onWechatMiniProgramShareAppMessageResolve") {
      let target = this.componentFactory.cachedView[message.target] as MPScaffold;
      if (target) {
        target.onWechatMiniProgramShareAppMessageResolver?.(message.params);
        target.onWechatMiniProgramShareAppMessageResolver = undefined;
      }
    }
  }

  didReceivedScrollView(message: any) {
    if (message.event === "onRefreshEnd") {
      let target = this.componentFactory.cachedView[message.target] as CollectionView;
      if (target) {
        target.refreshEndResolver?.(undefined);
        target.refreshEndResolver = undefined;
      }
    } else if (message.event === "jumpTo") {
      let target = this.componentFactory.cachedView[message.target] as CollectionView;
      if (target) {
        target.jumpTo(message.value);
      }
    }
  }

  didReceivedEditableText(message: any) {
    if (message.event === "unfocus") {
      let target = this.componentFactory.cachedView[message.target] as EditableText;
      if (target) {
        target.contentElement?.blur();
      }
    } else if (message.event === "focus") {
      let target = this.componentFactory.cachedView[message.target] as EditableText;
      if (target) {
        target.contentElement?.focus();
      }
    }
  }

  didReceivedMPJS(decodedMessage: any) {
    this.mpJS.handleMessage(
      decodedMessage.message,
      (result) => {
        this.sendMessage(
          JSON.stringify({
            type: "mpjs",
            message: {
              requestId: decodedMessage.message.requestId,
              result: result,
            },
          })
        );
      },
      (funcId: string, args: any[]) => {
        this.sendMessage(
          JSON.stringify({
            type: "mpjs",
            message: {
              funcId: funcId,
              arguments: args,
            },
          })
        );
      }
    );
  }

  async didReceivedPlatformView(message: any) {
    if (message.event === "methodCall") {
      let target = this.componentFactory.cachedView[message.hashCode] as MPPlatformView;
      if (target) {
        const result = await target.onMethodCall(message.method, message.params);
        if (message.requireResult) {
          this.sendMessage(
            JSON.stringify({
              type: "platform_view",
              message: {
                event: "methodCallCallback",
                seqId: message.seqId,
                result: result,
              },
            })
          );
        }
      }
    } else if (message.event === "methodCallCallback") {
      const seqId = message["seqId"];
      if (typeof seqId === "string") {
        MPPlatformView.handleInvokeMethodCallback(seqId, message["result"]);
      }
    }
  }

  private listenViewport() {
    if (__MP_TARGET_BROWSER__) {
      window.addEventListener("resize", () => {
        this.sendViewportChangeEvent();
      });
    }
  }

  private sendViewportHandler: any;

  private sendViewportChangeEvent() {
    if (this.sendViewportHandler) {
      clearTimeout(this.sendViewportHandler);
    }
    this.sendViewportHandler = setTimeout(() => {
      this.windowInfo.updateWindowInfo();
      (this.app?.router as any)?.history.forEach((it: any) => {
        it.item.viewportChanged();
      });
      this.sendViewportHandler = undefined;
    }, 32);
  }
}
