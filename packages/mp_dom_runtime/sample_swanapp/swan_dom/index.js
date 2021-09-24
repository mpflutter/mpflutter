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
    constructor(hashCode, controller, tag) {
        this.hashCode = hashCode;
        this.controller = controller;
        this.tag = tag;
        this.currentStyle = {};
        this.attributes = {};
        this.nodes = [];
        this.nodesHash = [];
        global.miniDomEventHandlers = _Element.eventHandlers;
    }
    get firstChild() {
        return this.nodes[0];
    }
    setClass(value) {
        if (this.class === value)
            return;
        this.class = value !== null && value !== void 0 ? value : "";
        this.setAttribute("class", value !== null && value !== void 0 ? value : "");
    }
    cloneNode(deep = false) {
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
    setTag(value) {
        this.tag = value;
        this.controller.pushCommand(`${this.hashCode}.tag`, value);
    }
    setStyle(style) {
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
            this.controller.pushCommand(`${this.hashCode}.s`, this.transformStyle(this.currentStyle));
        }
        else if (changed && changeCount === 1) {
            const cssKey = this.toCSSKey(changeKey);
            if (dictCSSKeys[cssKey]) {
                this.controller.pushCommand(`${this.hashCode}.s.${dictCSSKeys[cssKey]}`, this.transformCSSValue(this.currentStyle[changeKey]));
            }
            else {
                let transformedStyle = this.transformStyle(this.currentStyle);
                this.controller.pushCommand(`${this.hashCode}.s.other`, transformedStyle["other"]);
            }
        }
    }
    transformStyle(style) {
        let output = {};
        for (const key in style) {
            const cssKey = this.toCSSKey(key);
            if (dictCSSKeys[cssKey]) {
                output[dictCSSKeys[cssKey]] = this.transformCSSValue(style[key]);
            }
            else {
                if (!output["other"])
                    output["other"] = "";
                output["other"] += `${this.toCSSKey(key)}:${style[key]};`;
            }
        }
        return output;
    }
    transformCSSValue(value) {
        var _a;
        return (_a = dictCSSValues[value]) !== null && _a !== void 0 ? _a : value;
    }
    setAttribute(name, value) {
        this.attributes[name] = value;
        this.controller.pushCommand(`${this.hashCode}.${name}`, value);
    }
    removeAttribute(name) {
        delete this.attributes[name];
        this.controller.pushCommand(`${this.hashCode}.${name}`, undefined);
    }
    insertBefore(newChild, refChild) {
        const refIndex = refChild ? this.nodes.indexOf(refChild) : -1;
        if (refIndex >= 0) {
            if (newChild.parent) {
                newChild.parent.removeChild(newChild);
            }
            newChild.parent = this;
            this.nodes.splice(refIndex, 0, newChild);
            this.nodesHash.splice(refIndex, 0, newChild.hashCode);
            this.controller.pushCommand(`${this.hashCode}.n`, this.nodesHash);
        }
        else {
            this.appendChild(newChild);
        }
    }
    setChildrenLight(children) {
        this.nodes = children;
        this.nodesHash = children.map((it) => it.hashCode);
        return this.controller.pushCommand(`${this.hashCode}.n`, this.nodesHash);
    }
    appendChild(child) {
        if (child.parent) {
            child.parent.removeChild(child);
        }
        child.parent = this;
        this.nodes.push(child);
        this.nodesHash.push(child.hashCode);
        return this.controller.pushCommand(`${this.hashCode}.n`, this.nodesHash);
    }
    removeChild(child) {
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
        // if (this.class) {
        //   return this.getBoundingClientRectWithClass();
        // }
        return new Promise((res) => {
            swan
                .createSelectorQuery()
                .in(this.controller.componentInstance)
                .select("#d_" + this.hashCode)
                .boundingClientRect((result) => {
                if (!result) {
                    res({ width: 0.0, height: 0.0 });
                    return;
                }
                res({
                    width: result.width > 1 ? Math.ceil(result.width + 1) : 0.0,
                    height: result.height > 1 ? Math.ceil(result.height + 1) : 0.0,
                });
            })
                .exec();
        });
    }
    getBoundingClientRectWithClass() {
        if (!_Element.classBoundingClientRectQuery[this.class]) {
            _Element.classBoundingClientRectQuery[this.class] = swan
                .createSelectorQuery()
                .in(this.controller.componentInstance)
                .selectAll("." + this.class)
                .boundingClientRect((result) => {
                if (result instanceof Array) {
                    result.forEach((it) => {
                        var _a, _b;
                        (_b = (_a = _Element.classBoundingClientRectCallback)[it.id]) === null || _b === void 0 ? void 0 : _b.call(_a, {
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
    getFields(fields) {
        return new Promise((res) => {
            swan
                .createSelectorQuery()
                .in(this.controller.componentInstance)
                .select("#d_" + this.hashCode)
                .fields(fields)
                .exec((result) => {
                res(result[0]);
            });
        });
    }
    get clientWidth() {
        return swan.getSystemInfoSync().windowWidth;
    }
    get clientHeight() {
        return swan.getSystemInfoSync().windowHeight;
    }
    get windowPaddingTop() {
        return swan.getSystemInfoSync().statusBarHeight;
    }
    get windowPaddingBottom() {
        var _a, _b;
        return (_b = (_a = swan.getSystemInfoSync().safeArea) === null || _a === void 0 ? void 0 : _a.bottom) !== null && _b !== void 0 ? _b : 0;
    }
    get devicePixelRatio() {
        return swan.getSystemInfoSync().pixelRatio;
    }
    set onclick(value) {
        _Element.eventHandlers[`${this.hashCode}.onclick`] = value;
        this.controller.pushCommand(`${this.hashCode}.onclick`, value ? this.hashCode : undefined);
    }
    set oninput(value) {
        _Element.eventHandlers[`${this.hashCode}.oninput`] = value;
    }
    set onsubmit(value) {
        _Element.eventHandlers[`${this.hashCode}.onsubmit`] = value;
    }
    toCSSKey(str) {
        if (_Element.toCSSKeyCache[str])
            return _Element.toCSSKeyCache[str];
        let snakeCase = str.replace(/[A-Z]/g, (letter) => `-${letter.toLowerCase()}`);
        if (snakeCase.startsWith("webkit")) {
            snakeCase = `-${snakeCase}`;
        }
        _Element.toCSSKeyCache[str] = snakeCase;
        return snakeCase;
    }
}
_Element.eventHandlers = {};
_Element.classBoundingClientRectQuery = {};
_Element.classBoundingClientRectCallback = {};
_Element.toCSSKeyCache = {};
class _Document {
    constructor(controller) {
        this.controller = controller;
        this.body = new _Element("body", this.controller, "div");
    }
    createElement(tag) {
        const hashCode = _Document.nextElementHashCode.toString();
        _Document.nextElementHashCode++;
        if (tag !== "div") {
            this.controller.pushCommand(hashCode, {
                id: hashCode,
                tag,
                s: {},
                n: [],
            });
        }
        else {
            this.controller.pushCommand(hashCode, {
                id: hashCode,
                s: {},
                n: [],
            });
        }
        return new _Element(hashCode, this.controller, tag);
    }
    awaitSetState() {
        return new Promise((res) => {
            this.controller.commandPromises.push(res);
        });
    }
}
_Document.nextElementHashCode = 0;
class MiniDom {
    constructor() {
        this.document = new _Document(this);
        this.commands = [];
        this.commandPromises = [];
        this.needsSetData = false;
    }
    markNeedsSetData() {
        if (this.needsSetData)
            return;
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
                }
                else if (parentKey.endsWith(".s") &&
                    data[`dom.${parentKey.replace(".s", "")}`] &&
                    data[`dom.${parentKey.replace(".s", "")}`]["s"]) {
                    data[`dom.${parentKey.replace(".s", "")}`]["s"][myKey] =
                        command.value;
                }
                else {
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
    pushCommand(key, value) {
        this.commands.push({ key, value });
        this.markNeedsSetData();
    }
}
Component({
    properties: {
        s: { type: String },
    },
    data: {
        dom: { body: { id: "body", tag: "div", s: {}, n: [] } },
    },
    lifetimes: {
        attached() {
            this.miniDom = new MiniDom();
            this.miniDom.componentInstance = this;
            this.miniDom.setData = this.setData.bind(this);
        },
    },
});
