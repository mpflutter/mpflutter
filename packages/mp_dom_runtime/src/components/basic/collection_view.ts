import { MPEnv, PlatformType } from "../../env";
import { ComponentView } from "../component_view";
import { setDOMStyle } from "../dom_utils";
import { cssColor, cssSizeFromMPElement } from "../utils";
import { SliverPersistentHeader } from "./sliver_persistent_header";

export class CollectionView extends ComponentView {
  classname = "CollectionView";
  wrapperHtmlElement = this.document.createElement("div");
  appBarPinnedViews: ComponentView[] = [];
  appBarPersistentHeight = 0.0;
  enabledRestoration = false;
  lastScrollX: number = 0;
  lastScrollY: number = 0;
  viewWidth: number = 0;
  viewHeight: number = 0;
  bottomBarHeight: number = 0;
  bottomBarWithSafeArea = false;
  layout!: CollectionViewLayout;
  didAddScrollListener = false;

  constructor(document: Document, readonly initialAttributes?: any) {
    super(document, initialAttributes);
    this.htmlElement.appendChild(this.wrapperHtmlElement);
  }

  elementType() {
    if (this.initialAttributes?.restorationId && MPEnv.platformType == PlatformType.wxMiniProgram) {
      return "wx-scroll-view";
    } else {
      return "div";
    }
  }

  addScrollListener() {
    if (this.didAddScrollListener) return;
    this.didAddScrollListener = true;
    this.htmlElement.addEventListener("scroll", (e) => {
      this.lastScrollX = this.htmlElement.scrollLeft;
      this.lastScrollY = this.htmlElement.scrollTop;
    });
  }

  didMoveToWindow() {
    super.didMoveToWindow();
    if (this.enabledRestoration && MPEnv.platformType === PlatformType.browser) {
      this.htmlElement.scrollTo({
        left: this.lastScrollX,
        top: this.lastScrollY,
      });
      setTimeout(() => {
        this.htmlElement.scrollTo({
          left: this.lastScrollX,
          top: this.lastScrollY,
        });
      }, 0);
    } else if (this.enabledRestoration && MPEnv.platformType === PlatformType.wxMiniProgram) {
      this.htmlElement.setAttribute("scroll-top", this.lastScrollY.toFixed(0));
      this.htmlElement.setAttribute("scroll-left", this.lastScrollX.toFixed(0));
      setTimeout(() => {
        this.htmlElement.setAttribute("scroll-top", this.lastScrollY.toFixed(0));
        this.htmlElement.setAttribute("scroll-left", this.lastScrollX.toFixed(0));
      }, 0);
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
    let persistentYOffset = -this.appBarPersistentHeight;
    let persistentHSum = this.appBarPersistentHeight;
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
      if (subview instanceof SliverPersistentHeader && subview.pinned) {
        subview.y = subviewLayout.y - persistentYOffset;
        subview.h = persistentHSum;
        persistentYOffset += subview.y + (subview.constraints?.h ?? 0);
        persistentHSum += subview.constraints?.h ?? 0;
        subview.updateLayout();
      } else if (subview instanceof SliverPersistentHeader && subview.lazying) {
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
        ? `calc(${contentSize.height + this.bottomBarHeight}px + env(safe-area-inset-bottom))`
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
    if (attributes.restorationId && MPEnv.platformType == PlatformType.wxMiniProgram) {
      this.htmlElement.setAttribute("scroll-x", "true");
      this.htmlElement.setAttribute("scroll-y", "true");
      this.enabledRestoration = true;
      this.addScrollListener();
    } else if (attributes.restorationId && MPEnv.platformType == PlatformType.browser) {
      this.enabledRestoration = true;
      this.addScrollListener();
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
    const appBarPinnedView = this.factory.create(attributes.appBarPinned, this.document);
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
              appBarPinnedView.attributes?.color ?? appBarPinnedView.attributes?.backgroundColor
                ? cssColor(appBarPinnedView.attributes?.color ?? appBarPinnedView.attributes?.backgroundColor)
                : "unset",
          });
          this.appBarPersistentHeight = cssSizeFromMPElement(it).height;
        } else {
          setDOMStyle(it.htmlElement, { marginTop: -appBarH + "px" });
        }
        this.appBarPinnedViews.push(it);
      });
      this.appBarPinnedViews.reverse().forEach((it) => this.addSubviewForPinnedAppBar(it));
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
    if (this.wrapperHtmlElement.firstChild) {
      this.wrapperHtmlElement.insertBefore(view.htmlElement, this.wrapperHtmlElement.firstChild!);
    } else {
      this.wrapperHtmlElement.appendChild(view.htmlElement);
    }
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
