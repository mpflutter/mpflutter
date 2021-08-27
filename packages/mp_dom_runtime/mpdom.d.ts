export class Engine {
  static codeBlockWithCodePath(codePath: string): Promise<() => void>;
  static codeBlockWithFile(filePath: string): () => void;
  initWithDebuggerServerAddr(debuggerServerAddr: string);
  initWithCodeBlock(codeBlock: () => void);
  start();
}

export class BrowserApp {
  constructor(readonly rootElement: HTMLElement, readonly engine: Engine);
  setupFirstPage(options?: { route: string; params: any }): Promise<any>;
}

export class WXApp {
  constructor(readonly indexPage: string, readonly engine: Engine);
}

export class Page {
  constructor(
    readonly element: HTMLElement,
    readonly engine: Engine,
    readonly options?: { route: string; params: any },
    readonly document?: Document
  );
}

export class PlatformView {
  elementType(): string;
  onMessageFromDart(message: any): void;
  sendMessageToDart(message: any): void;
}

export function WXPage(
  options: { route: string; params: any },
  selector: string = "#vdom",
  app: WXApp = global.app
);

export function setDOMAttribute(
  element: HTMLElement,
  name: string,
  value: any
): void;

export function setDOMStyle(
  element: HTMLElement,
  style: CSSStyleDeclaration
): void;

export default mpdom;
