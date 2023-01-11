import { ComponentView } from "../component_view";
import { setDOMStyle } from "../dom_utils";
import { cssColor, cssColorHex } from "../utils";

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
    if (this.appBar === appBar && (appBar as any)?.collectionViewFixed !== true) return;
    this.removeAllSubviews();
    this.appBar = appBar;
    if (appBar) {
      (appBar as any).collectionViewFixed = false;
      setDOMStyle(appBar.htmlElement, {
        pointerEvents: "unset",
        display: "unset",
      });
      appBar.subviews.forEach((it) => {
        setDOMStyle(it.htmlElement, { position: "absolute", marginTop: "0px" });
      });
    }
    if (appBar && this.engine.pageMode) {
      appBar.additionalConstraints = { position: "fixed" };
      setDOMStyle(appBar.htmlElement, {
        position: "fixed",
        zIndex: "9999",
      });
    }
    this.readdSubviews();
  }

  setBody(body?: ComponentView) {
    if (this.body === body) return;
    this.removeAllSubviews();
    this.body = body;
    this.readdSubviews();
  }

  setBottomBar(bottomBar?: ComponentView, bottomBarWithSafeArea?: boolean, bottomBarSafeAreaColor?: string) {
    if (this.bottomBar === bottomBar) return;
    this.removeAllSubviews();
    this.bottomBar = bottomBar;
    if (bottomBar && this.engine.pageMode) {
      bottomBar.additionalConstraints = {
        position: "fixed",
        top: "unset",
      };
      setDOMStyle(bottomBar.htmlElement, {
        position: "fixed",
        top: "unset",
        bottom: "0px",
        zIndex: "9999",
        paddingBottom: bottomBarWithSafeArea === true ? "env(safe-area-inset-bottom)" : "",
        backgroundColor: bottomBarSafeAreaColor ? cssColor(bottomBarSafeAreaColor) : undefined,
      });
    }
    this.readdSubviews();
  }

  setFloatingBody(floatingBody?: ComponentView) {
    if (this.floatingBody === floatingBody) return;
    this.removeAllSubviews();
    this.floatingBody = floatingBody;
    if (floatingBody && this.engine.pageMode) {
      floatingBody.additionalConstraints = {
        position: "fixed",
        zIndex: "9999",
      };
      setDOMStyle(floatingBody.htmlElement, {
        position: "fixed",
        zIndex: "9999",
      });
    }
    this.readdSubviews();
  }

  readdSubviews() {
    if (this.body) {
      this.addSubview(this.body);
    }
    if (this.appBar) {
      this.addSubview(this.appBar);
    }
    if (this.bottomBar) {
      this.addSubview(this.bottomBar);
    }
    if (this.floatingBody) {
      this.addSubview(this.floatingBody);
    }
  }

  setAttributes(attributes: any) {
    super.setAttributes(attributes);
    this.setAppBar(attributes.appBar ? this.factory.create(attributes.appBar, this.document) : undefined);
    this.setBody(attributes.body ? this.factory.create(attributes.body, this.document) : undefined);
    this.setBottomBar(
      attributes.bottomBar ? this.factory.create(attributes.bottomBar, this.document) : undefined,
      attributes.bottomBarWithSafeArea,
      attributes.bottomBarSafeAreaColor
    );
    this.setFloatingBody(
      attributes.floatingBody ? this.factory.create(attributes.floatingBody, this.document) : undefined
    );
    if (attributes.name) {
      this.delegate?.setPageTitle(attributes.name);
    } else {
      this.delegate?.setPageTitle("");
    }
    if (this.delegate) {
      if (attributes.backgroundColor) {
        this.delegate?.setPageBackgroundColor(cssColorHex(attributes.backgroundColor));
      } else {
        this.delegate?.setPageBackgroundColor("transparent");
      }
    } else {
      setDOMStyle(this.htmlElement, {
        backgroundColor: attributes.backgroundColor ? cssColor(attributes.backgroundColor) : "unset",
      });
    }
    if (attributes.appBarColor) {
      this.delegate?.setAppBarColor(
        cssColorHex(attributes.appBarColor),
        attributes.appBarTintColor ? cssColorHex(attributes.appBarTintColor) : "#000000"
      );
    }
    if (this.body) {
      this.body.htmlElement.style.touchAction = attributes.hasRootScroller ? "unset" : "none";
    }
  }

  setDelegate(delegate?: MPScaffoldDelegate) {
    this.delegate = delegate;
  }

  onRefresh(): Promise<any> {
    return new Promise((res) => {
      this.refreshEndResolver = res;
      this.engine.sendMessage(
        JSON.stringify({
          type: "scaffold",
          message: {
            event: "onRefresh",
            target: this.hashCode,
          },
        })
      );
    });
  }

  onWechatMiniProgramShareAppMessage(info: any): Promise<any> {
    return new Promise((res) => {
      this.onWechatMiniProgramShareAppMessageResolver = res;
      this.engine.sendMessage(
        JSON.stringify({
          type: "scaffold",
          message: {
            event: "onWechatMiniProgramShareAppMessage",
            target: this.hashCode,
            from: info?.from,
            webViewUrl: info?.webViewUrl,
          },
        })
      );
    });
  }

  onWechatMiniProgramShareTimeline(): any {
    return this.attributes.wechatMiniProgramShareTimeline;
  }

  onWechatMiniProgramAddToFavorites(): any {
    return this.attributes.wechatMiniProgramAddToFavorites;
  }

  onReachBottom() {
    this.engine.sendMessage(
      JSON.stringify({
        type: "scaffold",
        message: {
          event: "onReachBottom",
          target: this.hashCode,
        },
      })
    );
  }

  onPageScroll(scrollTop: number) {
    if (!this.attributes.onPageScroll) return;
    this.engine.sendMessage(
      JSON.stringify({
        type: "scaffold",
        message: {
          event: "onPageScroll",
          target: this.hashCode,
          scrollTop,
        },
      })
    );
  }

  setChildren() {}
}
