declare var wx: any;
import { Engine } from "../engine";
import { MPEnv, PlatformType } from "../env";
import { BrowserDebugger } from "./browser_debugger";
import { WXDebugger } from "./wx_debugger";

export function createDebugger(serverAddr: string, engine: Engine): Debugger {
  if (MPEnv.platformType === PlatformType.wxMiniProgram) {
    return new WXDebugger(serverAddr, engine);
  } else {
    return new BrowserDebugger(serverAddr, engine);
  }
}

export interface Debugger {
  serverAddr: string;
  start(): void;
  sendMessage(message: string): void;
}
