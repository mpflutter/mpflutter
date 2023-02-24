import { CanvasPage } from "./canvaskit/canvas_page";
import { Engine } from "./engine";
import { Router } from "./router";

export class CanvasApp {
  router: CanvasRouter = new CanvasRouter(this.engine);
  currentPage?: CanvasPage

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
    const firstPage = new CanvasPage(this.canvasContext, this.engine);
    this.currentPage = firstPage;
    await firstPage.ready();
  }
}

class CanvasRouter extends Router {
  constructor(engine: Engine) {
    super(engine);
  }
}
