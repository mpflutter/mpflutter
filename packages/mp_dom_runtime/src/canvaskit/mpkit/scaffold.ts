import { ComponentView } from "../component_view";

export interface MPScaffoldDelegate {
  document: Document;
  setPageTitle(title: string): void;
  setPageBackgroundColor(color: string): void;
  setAppBarColor(color: string, tintColor?: string): void;
}

export class MPScaffold extends ComponentView {
  attached = false;
  appBar?: ComponentView;
  body?: ComponentView;
  bottomBar?: ComponentView;
  floatingBody?: ComponentView;
  delegate?: MPScaffoldDelegate;
  refreshEndResolver?: (_: any) => void;
  onWechatMiniProgramShareAppMessageResolver?: (_: any) => void;

  setAppBar(appBar?: ComponentView) {

  }

  setBody(body?: ComponentView) {
    this.body = body;
  }

  setBottomBar(bottomBar?: ComponentView, bottomBarWithSafeArea?: boolean, bottomBarSafeAreaColor?: string) {

  }

  setFloatingBody(floatingBody?: ComponentView) {

  }

  readdSubviews() {

  }

  setAttributes(attributes: any) {
    super.setAttributes(attributes);
    this.setBody(attributes.body ? this.factory.create(attributes.body) : undefined);
  }

  setDelegate(delegate?: MPScaffoldDelegate) {
    this.delegate = delegate;
  }

  setChildren() { }

  render(canvasContext: CanvasRenderingContext2D): void {
    if (this.body) {
      this.body.render(canvasContext);
    }
  }
}
