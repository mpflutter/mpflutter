import { Engine } from "../engine";
import { ComponentFactory } from "./component_factory";
import { setDOMStyle } from "./dom_utils";

interface Constraints {
  x: number;
  y: number;
  w: number;
  h: number;
}

export class ComponentView {
  classname = "";
  htmlElement: HTMLElement;
  superview?: ComponentView;
  subviews: ComponentView[] = [];
  factory!: ComponentFactory;
  engine!: Engine;
  hashCode!: number;
  attributes: any;
  constraints?: Constraints;
  additionalConstraints: any;
  collectionViewConstraints: any;
  protected disposed: boolean = false;

  ancestors: AncestorView[] = [];
  ancestorStyle: any = {};

  constructor(readonly document: Document, readonly initialAttributes?: any) {
    this.htmlElement = document.createElement(this.elementType());
    if (__MP_TARGET_WEAPP__) {
      this.htmlElement.getBoundingClientRect = (this.htmlElement as any).$$getBoundingClientRect;
    }
  }

  dispose() {
    this.disposed = true;
  }

  elementType(): string {
    return "div";
  }

  setConstraints(constraints?: Constraints) {
    if (!constraints) return;
    this.constraints = constraints;
    this.updateLayout();
  }

  updateLayout() {
    if (!this.constraints) return;
    let x: number = this.constraints.x;
    let y: number = this.constraints.y;
    let w: number = this.constraints.w;
    let h: number = this.constraints.h;
    this.ancestors.forEach((it) => {
      if (it.constraints) {
        x += it.constraints.x;
        y += it.constraints.y;
      }
    });
    let additionalConstraints = this.additionalConstraints;
    if (this.collectionViewConstraints && this.superview && this.superview.classname === "CollectionView") {
      additionalConstraints = this.collectionViewConstraints;
    }

    setDOMStyle(this.htmlElement, {
      position: additionalConstraints?.position ?? "absolute",
      left: additionalConstraints?.left ?? x + "px",
      top: additionalConstraints?.top ?? y + "px",
      width: additionalConstraints?.width ?? w + "px",
      height: additionalConstraints?.height ?? h + "px",
    });
  }

  setAttributes(attributes: any) {
    this.attributes = attributes;
  }

  setChildren(children: any) {
    if (!(children instanceof Array)) {
      return;
    }
    let makeSubviews = children.map((it) => this.factory.create(it, this.document)).filter((it) => it);
    let changed = false;
    let changedStartIndex = -1;
    if (makeSubviews.length !== this.subviews.length) {
      changed = true;
      for (let index = 0; index < makeSubviews.length; index++) {
        if (makeSubviews[index] !== this.subviews[index]) {
          changedStartIndex = index;
          break;
        }
      }
    } else {
      let allSame = makeSubviews.every((it, idx) => {
        return it === this.subviews[idx] && it.superview === this;
      });
      if (!allSame) {
        changed = true;
      }
    }
    if (changed) {
      if (changedStartIndex > 0) {
        let removingSubviews = [];
        for (let index = changedStartIndex; index < this.subviews.length; index++) {
          removingSubviews.push(this.subviews[index]);
        }
        removingSubviews.forEach((it) => it.removeFromSuperview());
        for (let index = changedStartIndex; index < makeSubviews.length; index++) {
          this.addSubview(makeSubviews[index]!);
        }
      } else {
        this.removeAllSubviews();
        makeSubviews.forEach((it) => this.addSubview(it!));
      }
    }
  }

  resetAncestorStyle() {
    if (this.ancestorStyle.opacity) {
      this.ancestorStyle.opacity = 1.0;
    }
    if (this.ancestorStyle.borderRadius) {
      this.ancestorStyle.borderRadius = "unset";
    }
    if (this.ancestorStyle.overflow) {
      this.ancestorStyle.overflow = "unset";
    }
    if (this.ancestorStyle.borderTopLeftRadius) {
      this.ancestorStyle.borderTopLeftRadius = "unset";
    }
    if (this.ancestorStyle.borderTopRightRadius) {
      this.ancestorStyle.borderTopRightRadius = "unset";
    }
    if (this.ancestorStyle.borderBottomLeftRadius) {
      this.ancestorStyle.borderBottomLeftRadius = "unset";
    }
    if (this.ancestorStyle.borderBottomRightRadius) {
      this.ancestorStyle.borderBottomRightRadius = "unset";
    }
  }

  setAncestors(ancestors: any) {
    if (!(ancestors instanceof Array) && this.ancestors.length > 0) {
      this.resetAncestorStyle();
      this.ancestors = [];
      setDOMStyle(this.htmlElement, this.ancestorStyle);
    } else {
      this.resetAncestorStyle();
      this.ancestors = ancestors
        .map((it: any) => this.factory.createAncestors(it, this))
        .filter((it: any) => it) as AncestorView[];
      setDOMStyle(this.htmlElement, this.ancestorStyle);
    }
  }

  removeAllSubviews() {
    this.subviews.forEach((it) => {
      it.superview = undefined;
      it.htmlElement.remove();
    });
    this.subviews = [];
  }

  removeFromSuperview() {
    if (!this.superview) return;
    const index = this.superview.subviews.indexOf(this);
    if (index >= 0) {
      this.superview.subviews[index].htmlElement.remove();
      this.superview?.subviews.splice(index, 1);
    }
    this.htmlElement.remove();
  }

  addSubview(view: ComponentView) {
    if (view.superview) {
      view.removeFromSuperview();
    }
    this.subviews.push(view);
    view.superview = this;
    this.htmlElement.appendChild(view.htmlElement);
    view.didMoveToWindow();
  }

  didMoveToWindow() {
    this.subviews.forEach((it) => it.didMoveToWindow());
  }
}

export class AncestorView {
  constraints?: Constraints;

  constructor(public target: ComponentView) {}

  setConstraints(constraints?: Constraints) {
    if (!constraints) return;
    this.constraints = constraints;
    this.target.updateLayout();
  }

  setAttributes(attributes: any) {}
}
