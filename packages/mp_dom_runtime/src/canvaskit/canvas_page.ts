import { Engine } from "../engine";
import { MPScaffold } from "./mpkit/scaffold";

export class CanvasPage {

  private scaffoldView?: MPScaffold;
  private readyCallback?: (_: any) => void;
  viewId: number = -1;

  constructor(readonly canvasContext: CanvasRenderingContext2D, readonly engine: Engine) {
    this.requestRoute().then((viewId: number) => {
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
    if (message.ignoreScaffold !== true) {
      const scaffoldView = this.engine.canvasComponentFactory.create(message.scaffold);
      if (!(scaffoldView instanceof MPScaffold)) return;
      if (this.scaffoldView !== scaffoldView) {
        if (this.scaffoldView) {
          this.scaffoldView.attached = false;
          this.scaffoldView.removeFromSuperview();
        }
        this.scaffoldView = scaffoldView;
        if (scaffoldView instanceof MPScaffold && !scaffoldView.delegate) {

        }
      }
    }
    this.render();
  }

  render() {
    this.canvasContext.clearRect(0, 0, 1000, 1000);
    if (this.scaffoldView) {
      this.scaffoldView.render(this.canvasContext);
    }
  }
}
