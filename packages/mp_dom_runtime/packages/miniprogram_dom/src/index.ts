declare var global: any;

const dictCSSKeys = {
  position: 1,
  top: 2,
  left: 3,
  width: 4,
  height: 5,
  "z-index": 6,
  "border-radius": 7,
  overflow: 8,
  "background-color": 9,
  display: 10,
  "user-select": 11,
  "-webkit-user-select": 12,
  "text-align": 13,
  "-webkit-line-clamp": 14,
  opacity: 15,
  "max-width": 16,
  "max-height": 17,
};

const dictCSSValues = {
  absolute: "_1",
  unset: "_2",
  start: "_3",
};

class _Element {
  static eventHandlers = {};

  private class: string | undefined;
  private currentStyle: CSSStyleDeclaration = {} as CSSStyleDeclaration;
  private attributes: { [key: string]: any } = {};
  private nodes: _Element[] = [];
  private nodesHash: string[] = [];
  parent: _Element | undefined;
  static classBoundingClientRectQuery: { [key: string]: any } = {};
  static classBoundingClientRectCallback: {
    [key: string]: (result: any) => void;
  } = {};

  get firstChild(): _Element | undefined {
    return this.nodes[0];
  }

  constructor(
    readonly hashCode: string,
    readonly controller: MiniDom,
    readonly tag: string
  ) {
    global.miniDomEventHandlers = _Element.eventHandlers;
  }

  setClass(value: string | undefined) {
    if (this.class === value) return;
    this.class = value ?? "";
    this.setAttribute("class", value ?? "");
  }

  cloneNode(deep: boolean = false) {
    const clonedElement = this.controller.document.createElement(this.tag);
    clonedElement.setStyle(this.currentStyle);
    for (const key in this.attributes) {
      clonedElement.setAttribute(key, this.attributes[key]);
    }
    if (deep) {
      this.nodes.forEach((it) => {
        clonedElement.appendChild(it.cloneNode(true));
      });
    }
    return clonedElement;
  }

  mpCloneNode() {
    const clonedElement = this.controller.document.createElement(this.tag);
    clonedElement.setStyle(this.currentStyle);
    for (const key in this.attributes) {
      clonedElement.setAttribute(key, this.attributes[key]);
    }
    clonedElement.setChildrenLight(this.nodes);
    return clonedElement;
  }

  setStyle(style: CSSStyleDeclaration) {
    let changed = false;
    let changeCount = 0;
    let changeKey = undefined;
    for (const key in style) {
      if (this.currentStyle[key] !== style[key]) {
        this.currentStyle[key] = style[key];
        changed = true;
        changeCount++;
        changeKey = key;
      }
    }
    if (changed && changeCount > 1) {
      this.controller.pushCommand(
        `${this.hashCode}.s`,
        this.transformStyle(this.currentStyle)
      );
    } else if (changed && changeCount === 1) {
      const cssKey = this.toCSSKey(changeKey);
      if (dictCSSKeys[cssKey]) {
        this.controller.pushCommand(
          `${this.hashCode}.s.${dictCSSKeys[cssKey]}`,
          this.transformCSSValue(this.currentStyle[changeKey])
        );
      } else {
        let transformedStyle = this.transformStyle(this.currentStyle);
        this.controller.pushCommand(
          `${this.hashCode}.s.other`,
          transformedStyle["other"]
        );
      }
    }
  }

  transformStyle(style: any) {
    let output: any = {};
    for (const key in style) {
      const cssKey = this.toCSSKey(key);
      if (dictCSSKeys[cssKey]) {
        output[dictCSSKeys[cssKey]] = this.transformCSSValue(style[key]);
      } else {
        if (!output["other"]) output["other"] = "";
        output["other"] += `${this.toCSSKey(key)}:${style[key]};`;
      }
    }
    return output;
  }

  transformCSSValue(value: any) {
    return dictCSSValues[value] ?? value;
  }

  setAttribute(name, value) {
    this.attributes[name] = value;
    this.controller.pushCommand(`${this.hashCode}.${name}`, value);
  }

  removeAttribute(name) {
    delete this.attributes[name];
    this.controller.pushCommand(`${this.hashCode}.${name}`, undefined);
  }

  insertBefore(newChild: _Element, refChild: _Element | undefined) {
    const refIndex = refChild ? this.nodes.indexOf(refChild) : -1;
    if (refIndex >= 0) {
      if (newChild.parent) {
        newChild.parent.removeChild(newChild);
      }
      newChild.parent = this;
      this.nodes.splice(refIndex, 0, newChild);
      this.nodesHash.splice(refIndex, 0, newChild.hashCode);
      this.controller.pushCommand(`${this.hashCode}.n`, this.nodesHash);
    } else {
      this.appendChild(newChild);
    }
  }

  setChildrenLight(children: _Element[]) {
    this.nodes = children;
    this.nodesHash = children.map((it) => it.hashCode);
    return this.controller.pushCommand(`${this.hashCode}.n`, this.nodesHash);
  }

  appendChild(child: _Element) {
    if (child.parent) {
      child.parent.removeChild(child);
    }
    child.parent = this;
    this.nodes.push(child);
    this.nodesHash.push(child.hashCode);
    return this.controller.pushCommand(`${this.hashCode}.n`, this.nodesHash);
  }

  removeChild(child: _Element) {
    const refIndex = this.nodes.indexOf(child);
    if (refIndex >= 0) {
      child.parent = undefined;
      this.nodes.splice(refIndex, 1);
      this.nodesHash.splice(refIndex, 1);
      this.controller.pushCommand(`${this.hashCode}.n`, this.nodesHash);
    }
  }

  remove() {
    if (this.parent) {
      this.parent.removeChild(this);
    }
  }

  getBoundingClientRect() {
    if (this.class) {
      return this.getBoundingClientRectWithClass();
    }
    return new Promise((res) => {
      wx.createSelectorQuery()
        .in(this.controller.componentInstance.selectComponent("#renderer"))
        .select("#d_" + this.hashCode)
        .boundingClientRect((result) => {
          res(result);
        })
        .exec();
    });
  }

  getBoundingClientRectWithClass() {
    if (!_Element.classBoundingClientRectQuery[this.class]) {
      _Element.classBoundingClientRectQuery[this.class] = wx
        .createSelectorQuery()
        .in(this.controller.componentInstance.selectComponent("#renderer"))
        .selectAll("." + this.class)
        .boundingClientRect((result) => {
          if (result instanceof Array) {
            result.forEach((it) => {
              _Element.classBoundingClientRectCallback[it.id]?.({
                width: it.width,
                height: it.height,
              });
              delete _Element.classBoundingClientRectCallback[it.id];
            });
          }
        });
      setTimeout(() => {
        _Element.classBoundingClientRectQuery[this.class].exec();
        delete _Element.classBoundingClientRectQuery[this.class];
      }, 16);
    }
    return new Promise((res) => {
      _Element.classBoundingClientRectCallback["d_" + this.hashCode] = res;
    });
  }

  getFields(fields: any) {
    return new Promise((res) => {
      wx.createSelectorQuery()
        .in(this.controller.componentInstance.selectComponent("#renderer"))
        .select("#d_" + this.hashCode)
        .fields(fields)
        .exec((result: any) => {
          res(result[0]);
        });
    });
  }

  get clientWidth(): number {
    return wx.getSystemInfoSync().windowWidth;
  }

  get clientHeight(): number {
    return wx.getSystemInfoSync().windowHeight;
  }

  get windowPaddingTop(): number {
    return wx.getSystemInfoSync().statusBarHeight;
  }

  get windowPaddingBottom(): number {
    return wx.getSystemInfoSync().safeArea?.bottom ?? 0;
  }

  get devicePixelRatio(): number {
    return wx.getSystemInfoSync().pixelRatio;
  }

  set onclick(value: () => void) {
    _Element.eventHandlers[`${this.hashCode}.onclick`] = value;
    this.controller.pushCommand(
      `${this.hashCode}.onclick`,
      value ? this.hashCode : undefined
    );
  }

  set oninput(value: () => void) {
    _Element.eventHandlers[`${this.hashCode}.oninput`] = value;
  }

  set onsubmit(value: () => void) {
    _Element.eventHandlers[`${this.hashCode}.onsubmit`] = value;
  }

  private static toCSSKeyCache: any = {};

  private toCSSKey(str: string) {
    if (_Element.toCSSKeyCache[str]) return _Element.toCSSKeyCache[str];
    let snakeCase = str.replace(
      /[A-Z]/g,
      (letter) => `-${letter.toLowerCase()}`
    );
    if (snakeCase.startsWith("webkit")) {
      snakeCase = `-${snakeCase}`;
    }
    _Element.toCSSKeyCache[str] = snakeCase;
    return snakeCase;
  }
}

class _Document {
  private static nextElementHashCode: number = 0;

  body = new _Element("body", this.controller, "div");

  constructor(readonly controller: MiniDom) {}

  createElement(tag: string) {
    const hashCode = _Document.nextElementHashCode.toString();
    _Document.nextElementHashCode++;
    if (tag !== "div") {
      this.controller.pushCommand(hashCode, { id: hashCode, tag });
    } else {
      this.controller.pushCommand(hashCode, { id: hashCode });
    }
    return new _Element(hashCode, this.controller, tag);
  }

  awaitSetState() {
    return new Promise((res) => {
      this.controller.commandPromises.push(res);
    });
  }
}

class MiniDom {
  document = new _Document(this);
  componentInstance: any;

  setData?: (data: any) => void;

  private commands: any[] = [];
  commandPromises: ((i: any) => void)[] = [];

  private needsSetData = false;

  private markNeedsSetData() {
    if (this.needsSetData) return;
    this.needsSetData = true;
    setTimeout(() => {
      const data = {};
      this.commands.forEach((command) => {
        let myKey = "";
        let parentKey = (() => {
          let k = command.key.split(".");
          myKey = k.pop();
          return k.join(".");
        })();
        if (data[`dom.${parentKey}`]) {
          data[`dom.${parentKey}`][myKey] = command.value;
        } else if (
          parentKey.endsWith(".s") &&
          data[`dom.${parentKey.replace(".s", "")}`] &&
          data[`dom.${parentKey.replace(".s", "")}`]["s"]
        ) {
          data[`dom.${parentKey.replace(".s", "")}`]["s"][myKey] =
            command.value;
        } else {
          data[`dom.${command.key}`] = command.value;
        }
      });
      // console.log("start set data", new Date().getTime());

      // const a = new Date().getTime();
      this.setData(data);
      // const b = new Date().getTime();
      // console.log(
      //   new Date().getTime(),
      //   "setdata",
      //   b - a,
      //   JSON.parse(JSON.stringify(data)),
      //   JSON.stringify(data).length
      // );
      // console.log("setdata", b - a);
      this.commandPromises.forEach((it) => it(null));
      this.commands = [];
      this.commandPromises = [];
      this.needsSetData = false;
    }, 16);
  }

  pushCommand(key: any, value: any) {
    this.commands.push({ key, value });
    this.markNeedsSetData();
  }
}

Component({
  properties: {
    s: { type: String },
  },
  data: {
    dom: { body: { id: "body", tag: "div", s: "", n: [] } },
  },
  lifetimes: {
    attached() {
      this.miniDom = new MiniDom();
      this.miniDom.componentInstance = this;
      this.miniDom.setData = this.setData.bind(this);
    },
  },
});
