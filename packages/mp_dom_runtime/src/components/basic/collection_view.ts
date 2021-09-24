import { MPEnv, PlatformType } from "../../env";
import { ComponentView } from "../component_view";
import { setDOMStyle } from "../dom_utils";
import { cssColor } from "../utils";
import { SliverPersistentHeader } from "./sliver_persistent_header";

export class CollectionView extends ComponentView {
  classname = "CollectionView";
  wrapperHtmlElement = this.document.createElement("div");
  appBarPinnedViews: ComponentView[] = [];
  lastScrollX: number = 0;
  lastScrollY: number = 0;
  viewWidth: number = 0;
  viewHeight: number = 0;
  bottomBarHeight: number = 0;
  bottomBarWithSafeArea = false;
  layout!: CollectionViewLayout;

  constructor(document: Document) {
    super(document);
    this.htmlElement.appendChild(this.wrapperHtmlElement);
    if (MPEnv.platformType === PlatformType.browser) {
      this.addBrowserScrollListener();
    }
  }

  addBrowserScrollListener() {
    this.htmlElement.addEventListener("scroll", (e) => {
      this.lastScrollX = this.htmlElement.scrollLeft;
      this.lastScrollY = this.htmlElement.scrollTop;
    });
  }

  didMoveToWindow() {
    super.didMoveToWindow();
    if (MPEnv.platformType === PlatformType.browser) {
      setTimeout(() => {
        this.htmlElement.scrollTo({
          left: this.lastScrollX,
          top: this.lastScrollY,
        });
      }, 1);
    }
  }

  setConstraints(constraints: any) {
    super.setConstraints(constraints);
    if (this.viewWidth !== constraints.w || this.viewHeight !== constraints.h) {
      this.viewWidth = constraints.w;
      this.viewHeight = constraints.h;
      this.reloadLayouts();
    }
  }

  reloadLayouts() {
    this.layout.prepareLayout();
    let persistentYOffset = 0.0;
    let persistentHSum = 0.0;
    for (let index = 0; index < this.subviews.length; index++) {
      let subview = this.subviews[index];
      let subviewLayout = this.layout.layoutAttributesForItemAtIndex(index);
      if (!subviewLayout) continue;
      subview.collectionViewConstraints = {
        top: subviewLayout.y.toFixed(1) + "px",
        left: subviewLayout.x.toFixed(1) + "px",
      };
      setDOMStyle(subview.htmlElement, {
        position: "absolute",
        top: subviewLayout.y.toFixed(1) + "px",
        left: subviewLayout.x.toFixed(1) + "px",
        width: subviewLayout.width.toFixed(1) + "px",
        height: subviewLayout.height.toFixed(1) + "px",
      });
      if (subview instanceof SliverPersistentHeader) {
        subview.y = subviewLayout.y - persistentYOffset;
        subview.h = persistentHSum;
        persistentYOffset += subview.y + (subview.constraints?.h ?? 0);
        persistentHSum += subview.constraints?.h ?? 0;
        subview.updateLayout();
      }
    }
    const contentSize = this.layout.collectionViewContentSize();
    setDOMStyle(this.wrapperHtmlElement, {
      position: "absolute",
      top: "0px",
      left: "0px",
      width: contentSize.width + "px",
      height: this.bottomBarWithSafeArea
        ? `calc(${
            contentSize.height + this.bottomBarHeight
          }px + env(safe-area-inset-bottom))`
        : contentSize.height + this.bottomBarHeight + "px",
    });
  }

  setAttributes(attributes: any) {
    super.setAttributes(attributes);
    setDOMStyle(this.htmlElement, {
      overflow: attributes.isRoot ? "unset" : "scroll",
    });
    this.bottomBarHeight = attributes.bottomBarHeight ?? 0.0;
    this.bottomBarWithSafeArea = attributes.bottomBarWithSafeArea ?? false;
    if (
      attributes.restorationId &&
      MPEnv.platformType == PlatformType.wxMiniProgram
    ) {
      (this.htmlElement as any).setTag("scrollview");
    }
  }

  addSubview(view: ComponentView) {
    if (view.superview) {
      view.removeFromSuperview();
    }
    this.subviews.push(view);
    view.superview = this;
    this.wrapperHtmlElement.appendChild(view.htmlElement);
    view.didMoveToWindow();
  }

  setPinnedAppBar(attributes: any) {
    const appBarPinnedView = this.factory.create(
      attributes.appBarPinned,
      this.document
    );
    if (appBarPinnedView) {
      (appBarPinnedView as any).collectionViewFixed = true;
      let appBarH = appBarPinnedView.constraints?.h ?? 0;
      let appBarY = 0.0;
      let stickyIndex = appBarPinnedView?.subviews.length === 1 ? 0 : 1;
      appBarPinnedView?.subviews.slice().forEach((it, idx) => {
        if (idx === stickyIndex - 1) {
          appBarY += it.constraints?.h ?? 0;
        }
        if (idx === stickyIndex) {
          setDOMStyle(it.htmlElement, {
            marginTop: -(appBarH - appBarY) + "px",
            top: "0px",
            position: "sticky",
            zIndex: "9999",
            backgroundColor:
              appBarPinnedView.attributes?.color ??
              appBarPinnedView.attributes?.backgroundColor
                ? cssColor(
                    appBarPinnedView.attributes?.color ??
                      appBarPinnedView.attributes?.backgroundColor
                  )
                : "unset",
          });
        } else {
          setDOMStyle(it.htmlElement, { marginTop: -appBarH + "px" });
        }
        this.appBarPinnedViews.push(it);
        this.addSubviewForPinnedAppBar(it);
      });
      setDOMStyle(appBarPinnedView.htmlElement, {
        pointerEvents: "none",
        display: "none",
      });
    }
  }

  addSubviewForPinnedAppBar(view: ComponentView) {
    if (view.superview) {
      view.removeFromSuperview();
    }
    view.superview = this;
    this.wrapperHtmlElement.appendChild(view.htmlElement);
    view.didMoveToWindow();
  }
}

export class CollectionViewLayout {
  constructor(readonly collectionView: CollectionView) {}

  prepareLayout() {}

  layoutAttributesForItemAtIndex(index: number): {
    x: number;
    y: number;
    width: number;
    height: number;
  } {
    throw "";
  }

  collectionViewContentSize(): { width: number; height: number } {
    throw "";
  }
}
