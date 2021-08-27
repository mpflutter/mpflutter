import { MPEnv, PlatformType } from "../../env";
import { ComponentView } from "../component_view";
import { setDOMAttribute } from "../dom_utils";

class PageViewWeb extends ComponentView {
  swiperInstance: any;
  wrapperHtmlElement = this.document.createElement("div");
  direction = "horizontal";
  loop = false;

  constructor(document: Document) {
    super(document);
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
    this.direction =
      attributes.scrollDirection === "Axis.vertical"
        ? "vertical"
        : "horizontal";
    this.loop = attributes.loop;
    this.wrapperHtmlElement.style.flexDirection =
      attributes.scrollDirection === "Axis.vertical" ? "column" : "row";
    this.setupSwiperInstance();
  }

  setupSwiperInstance() {
    setTimeout(() => {
      if (!this.swiperInstance) {
        this.swiperInstance = new (window as any).Swiper(
          "#d_" + this.hashCode,
          {
            direction: this.direction,
            loop: this.loop,
          }
        );
      } else {
        this.swiperInstance.changeDirection(this.direction);
        this.swiperInstance.update();
      }
    }, 16);
  }

  addSubview(view: ComponentView) {
    if (view.superview) {
      view.removeFromSuperview();
    }
    this.subviews.push(view);
    view.superview = this;
    this.wrapperHtmlElement.appendChild(view.htmlElement);
  }
}

class PageViewWeapp extends ComponentView {
  elementType() {
    return "swiper";
  }

  setAttributes(attributes: any) {
    super.setAttributes(attributes);
    setDOMAttribute(
      this.htmlElement,
      "vertical",
      attributes.scrollDirection === "Axis.vertical"
        ? (true as any)
        : (false as any)
    );
    setDOMAttribute(
      this.htmlElement,
      "circular",
      attributes.loop ? (true as any) : (false as any)
    );
  }
}

export const MPPageView =
  MPEnv.platformType === PlatformType.wxMiniProgram
    ? PageViewWeapp
    : PageViewWeb;
