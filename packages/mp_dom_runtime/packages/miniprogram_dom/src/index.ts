declare var global: any;

var EventEmitter = require("./event_emitter");

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

class _ClassList {
  value = [];

  constructor(readonly element: _Element) {}

  add(v: string) {
    if (this.value.indexOf(v) < 0) {
      this.value.push(v);
      this.element.setAttribute("class", this.value.join(" "));
    }
  }

  remove(v: string) {
    const idx = this.value.indexOf(v);
    if (idx >= 0) {
      this.value.splice(idx, 1);
      this.element.setAttribute("class", this.value.join(" "));
    }
  }

  toggle(v: string) {
    const idx = this.value.indexOf(v);
    if (idx >= 0) {
      this.value.splice(idx, 1);
    } else {
      this.value.push(v);
    }
    this.element.setAttribute("class", this.value.join(" "));
  }
}

class _Element extends EventEmitter {
  static eventHandlers = {};

  private classList: _ClassList = new _ClassList(this);
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

  constructor(readonly hashCode: string, readonly controller: MiniDom, public tag: string) {
    super();
    global.miniDomEventHandlers = _Element.eventHandlers;
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

  setTag(value: string) {
    this.tag = value;
    this.controller.pushCommand(`${this.hashCode}.tag`, value);
  }

  style = new Proxy(
    {},
    {
      set: (obj, prop, value) => {
        if (obj[prop] === value) return true;
        obj[prop] = value;
        this.controller.pushCommand(`${this.hashCode}.s`, this.transformStyle(obj));
        return true;
      },
    }
  );

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
    if (this.classList.value.length > 0) {
      return this.getBoundingClientRectWithClass();
    }
    let targetComponent = this.controller.componentInstance.selectComponent("#renderer").getComponent(this.hashCode);
    if (!targetComponent) {
      targetComponent = this.controller.componentInstance.selectComponent("#renderer");
    }
    return new Promise((res) => {
      wx.createSelectorQuery()
        .in(targetComponent)
        .select("#d_" + this.hashCode)
        .boundingClientRect((result) => {
          res(result);
        })
        .exec();
    });
  }

  getBoundingClientRectWithClass() {
    let className = this.classList.value[0];
    if (!_Element.classBoundingClientRectQuery[className]) {
      _Element.classBoundingClientRectQuery[className] = wx
        .createSelectorQuery()
        .in(this.controller.componentInstance.selectComponent("#renderer"))
        .selectAll("." + className)
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
        _Element.classBoundingClientRectQuery[className].exec();
        delete _Element.classBoundingClientRectQuery[className];
      }, 16);
    }
    return new Promise((res) => {
      _Element.classBoundingClientRectCallback["d_" + this.hashCode] = res;
    });
  }

  getFields(fields: any) {
    return new Promise((res) => {
      let targetComponent = this.controller.componentInstance.selectComponent("#renderer").getComponent(this.hashCode);
      if (!targetComponent) {
        targetComponent = this.controller.componentInstance.selectComponent("#renderer");
      }
      wx.createSelectorQuery()
        .in(targetComponent)
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

  addEventListener(event: string, callback: (e: any) => void) {
    _Element.eventHandlers[`${this.hashCode}`] = this;
    this.controller.pushCommand(`${this.hashCode}.${event}`, true);
    this.on(event, callback);
  }

  private static toCSSKeyCache: any = {};

  private toCSSKey(str: string) {
    if (_Element.toCSSKeyCache[str]) return _Element.toCSSKeyCache[str];
    let snakeCase = str.replace(/[A-Z]/g, (letter) => `-${letter.toLowerCase()}`);
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
  private commandsKeyPosition = {};
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
          data[`dom.${parentKey.replace(".s", "")}`]["s"][myKey] = command.value;
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
      this.commandsKeyPosition = {};
      this.commandPromises = [];
      this.needsSetData = false;
    }, 4);
  }

  pushCommand(key: any, value: any) {
    let position = this.commands.length;
    if (this.commandsKeyPosition[key] !== undefined) {
      this.commands[this.commandsKeyPosition[key]] = { key, value };
    } else {
      this.commands.push({ key, value });
      this.commandsKeyPosition[key] = position;
    }
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
      this.miniDom.setData = (data) => {
        this.selectComponent("#renderer").doSetData(data);
      };
    },
  },
});
