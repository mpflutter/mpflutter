import { ComponentView } from "../component_view";
import { setDOMStyle } from "../dom_utils";
import { SliverPersistentHeader } from "./sliver_persistent_header";

export class CollectionView extends ComponentView {
  wrapperHtmlElement = this.document.createElement("div");
  viewWidth: number = 0;
  viewHeight: number = 0;
  layout!: CollectionViewLayout;

  constructor(document: Document) {
    super(document);
    this.htmlElement.appendChild(this.wrapperHtmlElement);
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
      height: contentSize.height + "px",
    });
  }

  setAttributes(attributes: any) {
    super.setAttributes(attributes);
    setDOMStyle(this.htmlElement, {
      overflow: attributes.isRoot ? "unset" : "scroll",
    });
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
