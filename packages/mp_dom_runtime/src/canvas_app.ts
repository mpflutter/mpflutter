import { CanvasPage } from "./canvaskit/canvas_page";
import { Engine } from "./engine";
import { Router } from "./router";

export class CanvasApp {
  router: CanvasRouter = new CanvasRouter(this.engine);

  constructor(readonly canvasContext: CanvasRenderingContext2D, readonly engine: Engine) {
    engine.app = this;
  }

  async setupFirstPage(
    options?: {
      route: string;
      params: any;
    },
    reset?: boolean
  ) {
    console.log("setupFirstPage");
    
    const firstPage = new CanvasPage(this.canvasContext, this.engine);
    // firstPage.isFirst = true;
    await firstPage.ready();
  }
}

class CanvasRouter extends Router {
  constructor(engine: Engine) {
    super(engine);
  }
}
