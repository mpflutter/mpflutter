import { ComponentView } from "../component_view";

export class MPPlatformView extends ComponentView {
  private static _invokeMethodCompleter: { [key: string]: (result: any) => void } = {};

  static handleInvokeMethodCallback(seqId: string, result: any) {
    if (this._invokeMethodCompleter[seqId]) {
      this._invokeMethodCompleter[seqId](result);
      delete this._invokeMethodCompleter[seqId];
    }
  }

  classname = "PlatformView";
  _currentSize?: { width: number; height: number };

  constructor(readonly document: Document, readonly initialAttributes?: any) {
    super(document, initialAttributes);
    if (this.elementType().indexOf(".") > 0 && __MP_TARGET_BROWSER__) {
      this.htmlElement = this.createFromWebTemplate();
    } else if (initialAttributes?.tag && __MP_TARGET_BROWSER__) {
      this.htmlElement = document.createElement(initialAttributes.tag);
    }
    if (__MP_MINI_PROGRAM__) {
      this.htmlElement.getBoundingClientRect = (this.htmlElement as any).$$getBoundingClientRect;
    }
    this.htmlElement.id = "platform_view_" + Math.random().toString();
    this.htmlElement.setAttribute("id", this.htmlElement.id);
  }

  elementType() {
    return "div";
  }

  setSize(size: { width: number; height: number }) {
    if (this._currentSize && this._currentSize.width === size.width && this._currentSize.height === size.height) return;
    this._currentSize = size;
    this.engine.sendMessage(
      JSON.stringify({
        type: "platform_view",
        message: {
          event: "setSize",
          hashCode: this.hashCode,
          size,
        },
      })
    );
  }

  createFromWebTemplate(): HTMLElement {
    if (!__MP_TARGET_BROWSER__) return null!;
    let templateNode = document.getElementsByName(this.elementType())[0] as HTMLTemplateElement;
    if (!templateNode) {
      throw `Template ${this.elementType()} not found.`;
    }
    let clone = document.importNode(templateNode.content, true);
    return clone.children[0] as HTMLElement;
  }

  setAttributes(attributes: any): void {
    super.setAttributes(attributes);
    if (__MP_TARGET_BROWSER__) {
      let keys: string[] = [];
      try {
        keys = attributes.__keys__ ?? Object.keys(attributes);
      } catch (error) {
        keys = Object.keys(attributes);
      }
      keys.forEach((key) => {
        try {
          this.htmlElement.setAttribute(key, attributes[key]);
        } catch (error) {
          console.error(error);
        }
      });
    }
  }

  onMethodCall(method: string, params: any) {}

  invokeMethod(method: string, params: any, requireResult: boolean = false): Promise<any> | undefined {
    let seqId = `${this.hashCode}_${Math.random()}`;
    this.engine.sendMessage(
      JSON.stringify({
        type: "platform_view",
        message: {
          event: "methodCall",
          hashCode: this.hashCode,
          method,
          params,
          seqId,
          requireResult,
        },
      })
    );
    if (requireResult) {
      return new Promise((res) => {
        MPPlatformView._invokeMethodCompleter[seqId] = res;
      });
    }
  }
}
