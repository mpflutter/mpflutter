import { Engine } from "../engine";

export class CanvasPage {
  private readyCallback?: (_: any) => void;
  viewId: number = -1;

  constructor(readonly canvasContext: CanvasRenderingContext2D, readonly engine: Engine) {
    this.requestRoute().then((viewId: number) => {
      console.log("viewid", viewId);
      
      this.viewId = viewId;
      engine.managedViews[this.viewId] = this as any;
      engine.pageMode = true;
      if (engine.unmanagedViewFrameData[this.viewId]) {
        engine.unmanagedViewFrameData[this.viewId].forEach((it) => {
          this.didReceivedFrameData(it);
        });
        delete engine.unmanagedViewFrameData[this.viewId];
      }
      this.readyCallback?.(undefined);
    });
  }

  async ready(): Promise<any> {
    return new Promise((res) => {
      this.readyCallback = res;
    });
  }

  async requestRoute(): Promise<number> {
    const viewport = await this.fetchViewport();
    const router = this.engine.app?.router ?? this.engine?.router;
    return router!.requestRoute("/", {}, true, { width: viewport.width, height: viewport.height });
  }

  async fetchViewport(): Promise<any> {
    return { width: 375, height: 667 };
  }

  async didReceivedFrameData(message: { [key: string]: any }): Promise<void> {
    console.log(message);
  }
}
