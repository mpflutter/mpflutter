import { Engine } from "./engine";

export class Router {
  static beingPush = false;
  static beingPushTimeout: any;

  static clearBeingPushTimeout() {
    if (this.beingPushTimeout) {
      clearTimeout(this.beingPushTimeout);
      this.beingPushTimeout = undefined;
    }
  }

  constructor(readonly engine: Engine) {}

  routeResponseHandler: { [key: string]: (routeId: number) => void } = {};
  thePushingRouteId: number | undefined;

  async updateRoute(routeId: number, viewport: { width: number; height: number }) {
    this.engine.sendMessage(
      JSON.stringify({
        type: "router",
        message: {
          event: "updateRoute",
          routeId,
          viewport,
        },
      })
    );
  }

  async requestRoute(
    name: string,
    params: any,
    root: boolean,
    viewport: { width: number; height: number }
  ): Promise<number> {
    if (this.thePushingRouteId) {
      let value = this.thePushingRouteId;
      this.thePushingRouteId = undefined;
      this.engine.sendMessage(
        JSON.stringify({
          type: "router",
          message: {
            event: "updateRoute",
            routeId: value,
            viewport,
          },
        })
      );
      return value;
    }
    let requestId = Math.random().toString();
    return new Promise((res) => {
      this.routeResponseHandler[requestId] = res;
      this.engine.sendMessage(
        JSON.stringify({
          type: "router",
          message: {
            event: "requestRoute",
            requestId,
            name,
            params: params ?? {},
            viewport,
            root: root === true,
          },
        })
      );
    });
  }

  responseRoute(message: any) {
    let requestId = message.requestId;
    let routeId = message.routeId;
    this.routeResponseHandler[requestId]?.call(this, routeId);
  }

  disposeRoute(routeId: number) {
    this.engine.sendMessage(
      JSON.stringify({
        type: "router",
        message: {
          event: "disposeRoute",
          routeId,
        },
      })
    );
  }

  didReceivedRouteData(data: any) {
    const event = data.event;
    if (event === "responseRoute") {
      this.responseRoute(data);
    } else if (event === "didPush") {
      this.didPush(data);
    } else if (event === "didReplace") {
      this.didReplace(data);
    } else if (event === "didPop") {
      this.didPop();
    }
  }

  didPush(message: any) {
    throw "native implementation";
  }

  didReplace(message: any) {
    throw "native implementation";
  }

  didPop() {
    throw "native implementation";
  }
}
