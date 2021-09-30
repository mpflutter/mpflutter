import { Engine } from "../engine";
import { MPEnv } from "../env";
import { Debugger } from "./debugger";

export class WXDebugger implements Debugger {
  private messageQueue: string[] = [];
  private socket?: any;
  private connected = false;

  constructor(readonly serverAddr: string, readonly engine: Engine) {}

  start() {
    this.socket = MPEnv.platformScope.connectSocket({
      url: `ws://${this.serverAddr}/ws`,
    });
    this.socket.onOpen(() => {
      this.connected = true;
      this.socketDidConnect();
    });
    this.socket.onMessage((message: any) => {
      if (typeof message.data === "string") {
        this.socketDidReceiveMessage(message.data);
      }
    });
    this.socket!.onClose(() => {
      if (this.connected) {
        this.engine.componentFactory.cachedElement = {};
        this.engine.componentFactory.cachedView = {};
        MPEnv.platformScope.reLaunch({
          url: (() => {
            try {
              return (
                "/" +
                MPEnv.platformScope.getLaunchOptionsSync().path +
                "?" +
                this.encodePathParams(MPEnv.platformScope.getLaunchOptionsSync().query)
              );
            } catch (error) {
              return "/pages/index/index";
            }
          })(),
        });
      }
      this.connected = false;
      this.socketDidDisconnect();
    });
  }

  encodePathParams(params?: any): string {
    let searchParams: string[] = [];
    if (params) {
      for (const key in params) {
        searchParams.push(`${key}=${encodeURIComponent(params[key])}`);
      }
    }
    return searchParams.join("&");
  }

  socketDidConnect() {
    this.messageQueue.forEach((it) => {
      this.socket?.send({ data: it });
    });
    this.messageQueue = [];
  }

  socketDidDisconnect() {
    setTimeout(() => {
      this.start();
    }, 1000);
  }

  socketDidReceiveMessage(message: string) {
    this.engine.didReceivedMessage(message);
  }

  sendMessage(message: string) {
    if (!this.socket || !this.connected) {
      this.messageQueue.push(message);
      return;
    }
    this.socket.send({ data: message });
  }
}
