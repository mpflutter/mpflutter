import { MPPlatformView } from "../mpkit/platform_view";
import { ComponentView } from "../component_view";
import { setDOMAttribute } from "../dom_utils";

class PageViewWeb extends MPPlatformView {
  swiperInstance: any;
  wrapperHtmlElement = this.document.createElement("div");
  direction = "horizontal";
  loop = false;
  autoplay = false;

  constructor(document: Document, readonly initialAttributes?: any) {
    super(document, initialAttributes);
    this.wrapperHtmlElement.className = "swiper-wrapper";
    this.htmlElement.appendChild(this.wrapperHtmlElement);
  }

  setChildren(children: any) {
    super.setChildren(children);
    this.htmlElement.className = "swiper-container";
    this.htmlElement.id = "d_" + this.hashCode;
    this.subviews.forEach((it) => {
      it.htmlElement.className = "swiper-slide";
      it.htmlElement.style.position = "relative";
    });
    this.setupSwiperInstance();
  }

  setAttributes(attributes: any) {
    super.setAttributes(attributes);
    this.direction = attributes.scrollDirection === "Axis.vertical" ? "vertical" : "horizontal";
    this.loop = attributes.loop;
    this.autoplay = attributes.autoplay;
    this.wrapperHtmlElement.style.flexDirection = attributes.scrollDirection === "Axis.vertical" ? "column" : "row";
    this.setupSwiperInstance();
  }

  setupSwiperInstance() {
    setTimeout(() => {
      if (!this.swiperInstance) {
        this.swiperInstance = new (window as any).Swiper("#d_" + this.hashCode, {
          direction: this.direction,
          loop: this.loop,
          autoplay: this.autoplay,
          initialSlide: this.attributes.initialPage,
        });
        this.swiperInstance.on("activeIndexChange", () => {
          this.invokeMethod("onPageChanged", { index: this.swiperInstance.realIndex });
        });
      } else {
        this.swiperInstance.changeDirection(this.direction);
        this.swiperInstance.update();
      }
    }, 16);
  }

  onMethodCall(method: string, params: any) {
    if (method === "animateToPage") {
      this.swiperInstance.slideToLoop(params.page, typeof params.duration === "number" ? params.duration : 500);
    } else if (method === "jumpToPage") {
      this.swiperInstance.slideToLoop(params.page, 0);
    } else if (method === "nextPage") {
      this.swiperInstance.slideNext(typeof params.duration === "number" ? params.duration : 500);
    } else if (method === "previousPage") {
      this.swiperInstance.slidePrev(typeof params.duration === "number" ? params.duration : 500);
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
}

class PageViewWeapp extends MPPlatformView {
  maxPage = 0;
  currentPage = 0;

  constructor(readonly document: Document, readonly initialAttributes?: any) {
    super(document, initialAttributes);
    this.currentPage = initialAttributes.initialPage ?? 0;
    this.htmlElement.addEventListener("change", (event: any) => {
      this.currentPage = event.detail.current;
      this.invokeMethod("onPageChanged", { index: event.detail.current });
    });
    if (initialAttributes.initialPage) {
      this.htmlElement.setAttribute("current", initialAttributes.initialPage);
    }
  }

  elementType() {
    return "wx-swiper";
  }

  setChildren(children: any) {
    super.setChildren(children);
    this.maxPage = children.length - 1;
  }

  setAttributes(attributes: any) {
    super.setAttributes(attributes);
    setDOMAttribute(
      this.htmlElement,
      "vertical",
      attributes.scrollDirection === "Axis.vertical" ? (true as any) : (false as any)
    );
    setDOMAttribute(this.htmlElement, "circular", attributes.loop ? (true as any) : (false as any));
    setDOMAttribute(this.htmlElement, "autoplay", attributes.autoplay ? (true as any) : (false as any))
  }

  addSubview(view: ComponentView) {
    if (view.superview) {
      view.removeFromSuperview();
    }
    this.subviews.push(view);
    view.superview = this;
    let swiperItemElement = this.document.createElement("wx-swiper-item");
    swiperItemElement.appendChild(view.htmlElement);
    this.htmlElement.appendChild(swiperItemElement);
    view.didMoveToWindow();
  }

  onMethodCall(method: string, params: any) {
    let changePage = () => {
      this.htmlElement.setAttribute("duration", typeof params.duration === "number" ? params.duration : 500);
      setTimeout(() => {
        this.htmlElement.setAttribute("current", this.currentPage as any);
        this.htmlElement.setAttribute("duration", "500");
      }, 16);
    };
    if (method === "animateToPage") {
      this.currentPage = params.page;
      changePage();
    } else if (method === "jumpToPage") {
      this.currentPage = params.page;
      params.duration = 1;
      changePage();
    } else if (method === "nextPage") {
      this.currentPage = (this.currentPage + 1 > this.maxPage ? 0 : this.currentPage + 1) as any;
      changePage();
    } else if (method === "previousPage") {
      this.currentPage = (this.currentPage - 1 < 0 ? this.maxPage : this.currentPage - 1) as any;
      changePage();
    }
  }
}

export const MPPageView = (() => {
  if (__MP_MINI_PROGRAM__) {
    return PageViewWeapp;
  } else if (__MP_TARGET_BROWSER__) {
    return PageViewWeb;
  }
  throw "None of PageView class.";
})();
