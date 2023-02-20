import { Engine } from "../engine";
import { CanvasComponentFactory } from "./component_factory";

interface Constraints {
  x: number;
  y: number;
  w: number;
  h: number;
}

export class ComponentView {
  classname = "";
  superview?: ComponentView;
  subviews: ComponentView[] = [];
  factory!: CanvasComponentFactory;
  engine!: Engine;
  hashCode!: number;
  constraints?: Constraints;

  constructor(readonly initialAttributes?: any) {}

  setConstraints(constraints?: Constraints) {
    if (!constraints) return;
    this.constraints = constraints;
  }

  setAttributes(attributes: any) {}

  setChildren(children: any) {
    if (!(children instanceof Array)) {
      return;
    }
    let makeSubviews = children.map((it) => this.factory.create(it)).filter((it) => it);
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

  removeAllSubviews() {
    this.subviews.forEach((it) => {
      it.superview = undefined;
    });
    this.subviews = [];
  }

  removeFromSuperview() {
    if (!this.superview) return;
    const index = this.superview.subviews.indexOf(this);
    if (index >= 0) {
      this.superview?.subviews.splice(index, 1);
    }
  }

  addSubview(view: ComponentView) {
    if (view.superview) {
      view.removeFromSuperview();
    }
    this.subviews.push(view);
    view.superview = this;
    view.didMoveToWindow();
  }

  didMoveToWindow() {
    this.subviews.forEach((it) => it.didMoveToWindow());
  }

  renderTranslate(canvasContext: CanvasRenderingContext2D) {
    if (this.constraints && (this.constraints.x != 0 || this.constraints.y != 0)) {
      canvasContext.translate(this.constraints.x, this.constraints.y);
    }
  }

  renderSubviews(canvasContext: CanvasRenderingContext2D) {
    this.subviews.forEach((subview) => {
      subview.render(canvasContext);
    });
  }

  render(canvasContext: CanvasRenderingContext2D) {
    canvasContext.save();
    this.renderTranslate(canvasContext);
    this.renderSubviews(canvasContext);
    canvasContext.restore();
  }
}
