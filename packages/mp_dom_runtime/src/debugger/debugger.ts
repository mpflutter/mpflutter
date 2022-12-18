import { Engine } from "../engine";
import { MPEnv, PlatformType } from "../env";

export function createDebugger(serverAddr: string, engine: Engine): Debugger {
  if (__MP_MINI_PROGRAM__) {
    if (!__MP_MINI_PROGRAM__) return null!;
    return new WXDebugger(serverAddr, engine);
  } else {
    if (!__MP_TARGET_BROWSER__) return null!;
    return new BrowserDebugger(serverAddr, engine);
  }
}

export interface Debugger {
  serverAddr: string;
  start(): void;
  sendMessage(message: string): void;
  didConnectCallback?: () => void;
}

const clientType = () => {
  switch (MPEnv.platformType) {
    case PlatformType.browser:
      return "browser";
    case PlatformType.wxMiniProgram:
      return "wechatMiniProgram";
    case PlatformType.swanMiniProgram:
      return "swanMiniProgram";
    case PlatformType.ttMiniProgram:
      return "ttMiniProgram";
    default:
      return "unknown";
  }
};

class WXDebugger implements Debugger {
  private messageQueue: string[] = [];
  private socket?: any;
  private connected = false;
  private timeoutTimer: any;
  didConnectCallback?: () => void;

  constructor(readonly serverAddr: string, readonly engine: Engine) {}

  start() {
    MPEnv.platformScope.showToast &&
      MPEnv.platformScope.showToast({ title: "连接中", icon: "loading", duration: 10000 });
    this.socket = MPEnv.platformScope.connectSocket({
      url: `ws://${this.serverAddr}/ws?clientType=${clientType()}`,
    });
    this.timeoutTimer = setTimeout(() => {
      if (!this.socket.connected) {
        this.start();
      }
    }, 5000);
    this.socket.onOpen(() => {
      MPEnv.platformScope.hideToast && MPEnv.platformScope.hideToast();
      clearTimeout(this.timeoutTimer);
      this.connected = true;
      this.socketDidConnect();
      this.didConnectCallback?.();
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
    MPEnv.platformScope.showToast &&
      MPEnv.platformScope.showToast({ title: "尝试重新连接", icon: "loading", duration: 10000 });
    clearTimeout(this.timeoutTimer);
    setTimeout(() => {
      this.start();
    }, 5000);
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

class BrowserDebugger implements Debugger {
  private messageQueue: string[] = [];
  private socket?: WebSocket;
  private connected = false;
  private needReload = false;
  didConnectCallback?: () => void;

  constructor(readonly serverAddr: string, readonly engine: Engine) {}

  start() {
    let scheme = "ws";
    if (new URL(location.href).protocol === "https:") {
      scheme = "wss";
    }
    this.socket = new WebSocket(`${scheme}://${this.serverAddr}/ws?clientType=${clientType()}`);
    this.socket.onopen = () => {
      if (this.needReload) {
        location.href = "?";
        return;
      }
      this.socketDidConnect();
      this.connected = true;
      this.didConnectCallback?.();
    };
    this.socket.onmessage = (message) => {
      if (typeof message.data === "string") {
        this.socketDidReceiveMessage(message.data);
      }
    };
    this.socket.onclose = () => {
      this.needReload = true;
      this.socketDidDisconnect();
    };
  }

  socketDidConnect() {
    this.messageQueue.forEach((it) => {
      this.socket?.send(it);
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
    if (!this.socket || this.socket.readyState != 1) {
      this.messageQueue.push(message);
      return;
    }
    this.socket.send(message);
  }
}
