import { Engine } from "../engine";
import { Debugger } from "./debugger";

export class BrowserDebugger implements Debugger {
  private messageQueue: string[] = [];
  private socket?: WebSocket;
  private connected = false;
  private needReload = false;

  constructor(readonly serverAddr: string, readonly engine: Engine) {}

  start() {
    let scheme = "ws";
    if (new URL(location.href).protocol === "https:") {
      scheme = "wss";
    }
    this.socket = new WebSocket(`${scheme}://${this.serverAddr}/ws`);
    this.socket.onopen = () => {
      if (this.needReload) {
        location.href = "?";
        return;
      }
      this.socketDidConnect();
      this.connected = true;
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
