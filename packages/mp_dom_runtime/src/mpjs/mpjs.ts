import { Engine } from "../engine";
import { MPEnv } from "../env";
import { decode as decodeBase64, encode as encodeBase64 } from "base64-arraybuffer";

interface MPJSMessage {
  event: string;
  requestId: string;
  params: any;
}

interface MPJSCallMethodParams {
  objectHandler: string;
  callChain: string[];
  method: string;
  args: any[];
}

interface MPJSNewObjectParams {
  objectHandler: string;
  callChain: string[];
  clazz: string;
  args: any[];
}

interface MPJSGetValueParams {
  objectHandler: string;
  callChain: string[];
  key: string;
}

interface MPJSSetValueParams {
  objectHandler: string;
  callChain: string[];
  key: string;
  value: any;
}

export class MPJS {
  engineScope: { [key: string]: any } = {};
  objectRefs: { [key: string]: any } = {};
  funcRefs: { [key: string]: any } = {};

  constructor(readonly engine: Engine) {}

  handleMessage(
    message: MPJSMessage,
    callback: (result: any) => void,
    funcCallback: (funcId: string, args: any[]) => void
  ) {
    if (message.event === "callMethod") {
      this.callMethod(message, callback, funcCallback);
    } else if (message.event === "newObject") {
      this.newObject(message, callback, funcCallback);
    } else if (message.event === "getValue") {
      this.getValue(message, callback);
    } else if (message.event === "setValue") {
      this.setValue(message, callback);
    } else if (message.event === "hasProperty") {
      this.hasProperty(message, callback);
    } else if (message.event === "deleteProperty") {
      this.deleteProperty(message, callback);
    }
  }

  async callMethod(
    message: MPJSMessage,
    callback: (result: any) => void,
    funcCallback: (funcId: string, args: any[]) => void
  ) {
    const params = message.params as MPJSCallMethodParams;
    const callingObject = this.getCallee(params.objectHandler, params.callChain);
    if (typeof callingObject === "object" || typeof callingObject === "function") {
      try {
        let result = (callingObject[params.method] as Function).apply(
          callingObject,
          params.args?.map((it) => this.wrapArgument(it, funcCallback))
        );
        if (result instanceof Promise) {
          result = await result;
        }
        callback(this.wrapResult(result, params.method === "base64ToArrayBuffer"));
      } catch (error) {
        console.error(error);
      }
    }
  }

  async newObject(
    message: MPJSMessage,
    callback: (result: any) => void,
    funcCallback: (funcId: string, args: any[]) => void
  ) {
    const params = message.params as MPJSNewObjectParams;
    const callingObject = this.getCallee(params.objectHandler, params.callChain);
    if (typeof callingObject === "object" || typeof callingObject === "function") {
      try {
        let result = new callingObject[params.clazz](params.args?.map((it) => this.wrapArgument(it, funcCallback)));
        if (result instanceof Promise) {
          result = await result;
        }
        callback(this.wrapResult(result));
      } catch (error) {
        console.error(error);
      }
    }
  }

  async getValue(message: MPJSMessage, callback: (result: any) => void) {
    const params = message.params as MPJSGetValueParams;
    console.log("params", params)
    if (params.key === "" && params.callChain.length > 0) {
      let newCallChain: string[] = [];
      for (let index = 0; index < params.callChain.length; index++) {
        newCallChain.push(params.callChain[index]);
      }
      let newKey = newCallChain.pop() as string;
      const callingObject = this.getCallee(params.objectHandler, newCallChain);
      let result = callingObject[newKey];
      if (result instanceof Promise) {
        result = await result;
      }
      callback(this.wrapResult(result));
    } else {
      const callingObject = this.getCallee(params.objectHandler, params.callChain);
      let result = params.key === "" ? callingObject : callingObject[params.key];
      if (result instanceof Promise) {
        result = await result;
      }
      callback(this.wrapResult(result));
    }
  }

  setValue(message: MPJSMessage, callback: (result: any) => void) {
    const params = message.params as MPJSSetValueParams;
    const callingObject = this.getCallee(params.objectHandler, params.callChain);
    callingObject[params.key] = params.value;
    callback(undefined);
  }

  hasProperty(message: MPJSMessage, callback: (result: any) => void) {
    const params = message.params as MPJSGetValueParams;
    const callingObject = this.getCallee(params.objectHandler, params.callChain);
    callback(this.wrapResult(callingObject && callingObject.hasOwnProperty(params.key)));
  }

  deleteProperty(message: MPJSMessage, callback: (result: any) => void) {
    const params = message.params as MPJSGetValueParams;
    const callingObject = this.getCallee(params.objectHandler, params.callChain);
    if (callingObject) {
      delete callingObject[params.key];
    }
    callback(1);
  }

  getCallee(objectHandler: string, callChain: string[]): any {
    const rootObject = this.objectRefs[objectHandler] ?? MPEnv.platformGlobal();
    let currentObject: any = rootObject;
    if (callChain[0] === "engineScope") {
      currentObject = this.engineScope;
      callChain.shift();
    }
    for (let index = 0; index < callChain.length; index++) {
      const key = callChain[index] as any;
      currentObject = currentObject[key];
      if (key === "document" && index === 0 && currentObject === undefined) {
        currentObject = this.engine?.managedViews?.[0]?.document;
      }
      if (currentObject === undefined || currentObject === null) {
        break;
      }
    }
    return currentObject;
  }

  wrapArgument(arg: any, funcCallback: (funcId: string, args: any[]) => void): any {
    if (typeof arg === "string" && arg.indexOf("func:") === 0) {
      const funcId = arg;
      const self = this;
      const func =
        this.funcRefs[arg] ??
        function () {
          let cbArgs = [];
          for (let index = 0; index < arguments.length; index++) {
            const element = arguments[index];
            cbArgs.push(self.wrapResult(element));
          }
          funcCallback(funcId, cbArgs);
        };
      this.funcRefs[arg] = func;
      return func;
    } else if (typeof arg === "string" && arg.indexOf("obj:") === 0) {
      return this.objectRefs[arg.replace("obj:", "")];
    } else if (typeof arg === "string" && arg.indexOf("base64:") === 0) {
      if (__MP_TARGET_BROWSER__) {
        return decodeBase64(arg.substring(7));
      } else if (__MP_MINI_PROGRAM__) {
        return MPEnv.platformScope.base64ToArrayBuffer(arg.substring(7));
      }
    } else if (typeof arg === "object" && arg instanceof Array) {
      return arg.map((it) => this.wrapArgument(it, funcCallback));
    } else if (typeof arg === "object") {
      let newArgs: any = {};
      for (const key in arg) {
        newArgs[key] = this.wrapArgument(arg[key], funcCallback);
      }
      return newArgs;
    } else {
      return arg;
    }
  }

  wrapResult(result: any, forceUseObjectRef: boolean = false): any {
    if (
      typeof result === "string" ||
      typeof result === "number" ||
      typeof result === "boolean" ||
      typeof result === "bigint"
    ) {
      return result;
    } else if (typeof result === "object" && result instanceof ArrayBuffer && !forceUseObjectRef) {
      if (__MP_TARGET_BROWSER__) {
        return "base64:" + encodeBase64(result);
      } else if (__MP_MINI_PROGRAM__) {
        return "base64:" + MPEnv.platformScope.arrayBufferToBase64(result);
      }
    } else if (typeof result === "object" && result instanceof Array) {
      return result.map((it) => this.wrapResult(it));
    } else {
      const objectHandler = Math.random().toString();
      this.objectRefs[objectHandler] = result;
      return { objectHandler: objectHandler };
    }
  }
}
