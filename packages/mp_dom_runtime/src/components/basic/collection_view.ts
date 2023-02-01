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
  appBarPinnedPlained = false;
  enabledRestoration = false;
  lastScrollX: number = 0;
  lastScrollY: number = 0;
  viewWidth: number = 0;
  viewHeight: number = 0;
  bottomBarHeight: number = 0;
  bottomBarWithSafeArea = false;
  reverse = false;
  layout!: CollectionViewLayout;
  didAddScrollListener = false;
  didAddRefreshListener = false;
  didAddScrollToLowerListener = false;
  refreshEndResolver?: (_: any) => void;

  constructor(document: Document, readonly initialAttributes?: any) {
    super(document, initialAttributes);
    this.htmlElement.appendChild(this.wrapperHtmlElement);
  }

  elementType() {
    if (__MP_MINI_PROGRAM__ && this.initialAttributes?.isRoot !== true) {
      return "wx-scroll-view";
    } else {
      return "div";
    }
  }

  dispose() {
    if (this.didAddScrollListener) {
      MPEnv.platformWindow(this.document)?.removeEventListener("scroll", this.onWindowScrollEvent);
      this.htmlElement.removeEventListener("scroll", this.onScrollEvent);
    }
  }

  onWindowScrollEvent() {
    if (MPEnv.platformWindow(this.document)?.mpCurrentScrollView !== this) return;
    const window = MPEnv.platformWindow(this.document);
    if (!window) return;
    if (window.scrollX === this.lastScrollX && window.scrollY === this.lastScrollY) return;
    this.lastScrollX = window.scrollX;
    this.lastScrollY = window.scrollY;
    if (this.attributes.onScroll) {
      this.engine.sendMessage(
        JSON.stringify({
          type: "scroll_view",
          message: {
            event: "onScroll",
            target: this.attributes.onScroll,
            scrollLeft: window.scrollX,
            scrollTop: window.scrollY,
            viewportDimension: window.innerHeight,
            scrollHeight: this.document.body.scrollHeight,
          },
        })
      );
    }
  }

  addWindowScrollListener() {
    if (this.didAddScrollListener) return;
    this.didAddScrollListener = true;
    MPEnv.platformWindow(this.document)?.addEventListener("scroll", this.onWindowScrollEvent.bind(this));
  }

  onScrollEvent() {
    if (this.htmlElement.scrollLeft === this.lastScrollX && this.htmlElement.scrollTop === this.lastScrollY) return;
    this.lastScrollX = this.htmlElement.scrollLeft;
    this.lastScrollY = this.htmlElement.scrollTop;
    if (this.attributes.onScroll) {
      this.engine.sendMessage(
        JSON.stringify({
          type: "scroll_view",
          message: {
            event: "onScroll",
            target: this.attributes.onScroll,
            isRoot: this.attributes.isRoot,
            scrollLeft: this.htmlElement.scrollLeft,
            scrollTop: this.htmlElement.scrollTop,
            viewportDimension: this.constraints?.h ?? 0,
            scrollHeight: this.htmlElement.scrollHeight,
          },
        })
      );
    }
    if (this.htmlElement.scrollTop + this.htmlElement.clientHeight >= this.htmlElement.scrollHeight) {
      this.onScrollToLowerEvent();
    }
  }

  addScrollListener() {
    if (this.didAddScrollListener) return;
    this.didAddScrollListener = true;
    this.htmlElement.addEventListener("scroll", this.onScrollEvent.bind(this));
  }

  async onRefreshEvent() {
    await (() => {
      return new Promise((res) => {
        this.refreshEndResolver = res;
        this.engine.sendMessage(
          JSON.stringify({
            type: "scroll_view",
            message: {
              event: "onRefresh",
              target: this.hashCode,
              isRoot: this.attributes.isRoot,
            },
          })
        );
      });
    })();
    this.htmlElement.setAttribute("refresher-triggered", "false");
  }

  addRefreshListener() {
    if (this.didAddRefreshListener) return;
    this.didAddRefreshListener = true;
    this.htmlElement.addEventListener("refresherrefresh", this.onRefreshEvent.bind(this));
  }

  onScrollToLowerEvent() {
    this.engine.sendMessage(
      JSON.stringify({
        type: "scroll_view",
        message: {
          event: "onScrollToLower",
          target: this.hashCode,
          isRoot: this.attributes.isRoot,
        },
      })
    );
  }

  jumpTo(value: number) {
    if (__MP_TARGET_BROWSER__) {
      if (this.htmlElement.isConnected && this.attributes.isRoot) {
        window.scrollTo({ top: value });
      } else {
        this.htmlElement.scrollTo({
          left: this.attributes.scrollDirection === "Axis.horizontal" ? value : undefined,
          top: this.attributes.scrollDirection !== "Axis.horizontal" ? value : undefined,
        });
      }
    } else if (__MP_MINI_PROGRAM__) {
      if (this.attributes.isRoot) {
        MPEnv.platformGlobal().pageScrollTo({ scrollTop: value });
      } else {
        if (this.attributes.scrollDirection === "Axis.horizontal") {
          this.htmlElement.setAttribute("scroll-left", value.toString());
        } else {
          this.htmlElement.setAttribute("scroll-top", value.toString());
        }
      }
    }
  }

  addScrollToLowerListener() {
    if (this.didAddScrollToLowerListener) return;
    this.didAddScrollToLowerListener = true;
    this.htmlElement.addEventListener("scrolltolower", this.onScrollToLowerEvent.bind(this));
  }

  didMoveToWindow() {
    super.didMoveToWindow();
    if (this.enabledRestoration && __MP_TARGET_BROWSER__) {
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
    } else if (this.enabledRestoration && __MP_TARGET_WEAPP__) {
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
    let persistentYOffset = this.appBarPinnedPlained ? 0 : -this.appBarPersistentHeight;
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
        ? `calc(${
            contentSize.height + (this.elementType() === "div" ? this.bottomBarHeight : 0)
          }px + env(safe-area-inset-bottom))`
        : contentSize.height + (this.elementType() === "div" ? this.bottomBarHeight : 0) + "px",
    });
  }

  setAttributes(attributes: any) {
    super.setAttributes(attributes);
    let overflow = "scroll";
    if (attributes.scrollDisabled) {
      overflow = "hidden";
    } else if (attributes.isRoot) {
      overflow = "unset";
    }
    setDOMStyle(this.htmlElement, {
      overflow,
    });
    this.bottomBarHeight = attributes.bottomBarHeight ?? 0.0;
    this.bottomBarWithSafeArea = attributes.bottomBarWithSafeArea ?? false;
    if (attributes.restorationId && __MP_TARGET_WEAPP__) {
      this.enabledRestoration = true;
    } else if (attributes.restorationId && __MP_TARGET_BROWSER__) {
      this.enabledRestoration = true;
    }
    this.htmlElement.setAttribute("scroll-x", this.attributes.scrollDirection === "Axis.horizontal" ? "true" : "false");
    this.htmlElement.setAttribute("scroll-y", this.attributes.scrollDirection !== "Axis.horizontal" ? "true" : "false");
    this.reverse = attributes.reverse;
    setDOMStyle(this.htmlElement, {
      transform: this.reverse
        ? this.attributes.scrollDirection === "Axis.horizontal"
          ? "scale(-1.0, 1.0)"
          : "scale(1.0, -1.0)"
        : "unset",
    });
    this.updateSubviewTransform();
    if (attributes.isRoot && this.elementType() === "div") {
      let window = MPEnv.platformWindow(this.document);
      if (window) {
        window.mpCurrentScrollView = this;
      }
      this.addWindowScrollListener();
    } else {
      this.addScrollListener();
      this.addRefreshListener();
      this.addScrollToLowerListener();
      this.htmlElement.setAttribute("refresher-enabled", attributes["onRefresh"] ? "true" : "false");
    }
  }

  addSubview(view: ComponentView) {
    setDOMStyle(view.htmlElement, {
      transform: this.reverse
        ? this.attributes.scrollDirection === "Axis.horizontal"
          ? "scale(-1.0, 1.0)"
          : "scale(1.0, -1.0)"
        : "unset",
    });
    if (view.superview) {
      view.removeFromSuperview();
    }
    this.subviews.push(view);
    view.superview = this;
    this.wrapperHtmlElement.appendChild(view.htmlElement);
    view.didMoveToWindow();
  }

  updateSubviewTransform() {
    this.subviews.forEach((it) => {
      setDOMStyle(it.htmlElement, {
        transform: this.reverse
          ? this.attributes.scrollDirection === "Axis.horizontal"
            ? "scale(-1.0, 1.0)"
            : "scale(1.0, -1.0)"
          : "unset",
      });
    });
  }

  setPinnedAppBar(attributes: any) {
    if (attributes.appBarPinnedPlained) {
      const appBarPinnedView = this.factory.create(attributes.appBarPinned, this.document);
      this.appBarPersistentHeight = cssSizeFromMPElement(appBarPinnedView).height;
      this.appBarPinnedPlained = true;
      return;
    }
    this.appBarPinnedPlained = false;
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
