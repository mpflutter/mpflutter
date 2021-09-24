module.exports =
/******/ (function(modules) { // webpackBootstrap
/******/ 	// The module cache
/******/ 	var installedModules = {};
/******/
/******/ 	// The require function
/******/ 	function __webpack_require__(moduleId) {
/******/
/******/ 		// Check if module is in cache
/******/ 		if(installedModules[moduleId]) {
/******/ 			return installedModules[moduleId].exports;
/******/ 		}
/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = installedModules[moduleId] = {
/******/ 			i: moduleId,
/******/ 			l: false,
/******/ 			exports: {}
/******/ 		};
/******/
/******/ 		// Execute the module function
/******/ 		modules[moduleId].call(module.exports, module, module.exports, __webpack_require__);
/******/
/******/ 		// Flag the module as loaded
/******/ 		module.l = true;
/******/
/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}
/******/
/******/
/******/ 	// expose the modules object (__webpack_modules__)
/******/ 	__webpack_require__.m = modules;
/******/
/******/ 	// expose the module cache
/******/ 	__webpack_require__.c = installedModules;
/******/
/******/ 	// define getter function for harmony exports
/******/ 	__webpack_require__.d = function(exports, name, getter) {
/******/ 		if(!__webpack_require__.o(exports, name)) {
/******/ 			Object.defineProperty(exports, name, { enumerable: true, get: getter });
/******/ 		}
/******/ 	};
/******/
/******/ 	// define __esModule on exports
/******/ 	__webpack_require__.r = function(exports) {
/******/ 		if(typeof Symbol !== 'undefined' && Symbol.toStringTag) {
/******/ 			Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' });
/******/ 		}
/******/ 		Object.defineProperty(exports, '__esModule', { value: true });
/******/ 	};
/******/
/******/ 	// create a fake namespace object
/******/ 	// mode & 1: value is a module id, require it
/******/ 	// mode & 2: merge all properties of value into the ns
/******/ 	// mode & 4: return value when already ns object
/******/ 	// mode & 8|1: behave like require
/******/ 	__webpack_require__.t = function(value, mode) {
/******/ 		if(mode & 1) value = __webpack_require__(value);
/******/ 		if(mode & 8) return value;
/******/ 		if((mode & 4) && typeof value === 'object' && value && value.__esModule) return value;
/******/ 		var ns = Object.create(null);
/******/ 		__webpack_require__.r(ns);
/******/ 		Object.defineProperty(ns, 'default', { enumerable: true, value: value });
/******/ 		if(mode & 2 && typeof value != 'string') for(var key in value) __webpack_require__.d(ns, key, function(key) { return value[key]; }.bind(null, key));
/******/ 		return ns;
/******/ 	};
/******/
/******/ 	// getDefaultExport function for compatibility with non-harmony modules
/******/ 	__webpack_require__.n = function(module) {
/******/ 		var getter = module && module.__esModule ?
/******/ 			function getDefault() { return module['default']; } :
/******/ 			function getModuleExports() { return module; };
/******/ 		__webpack_require__.d(getter, 'a', getter);
/******/ 		return getter;
/******/ 	};
/******/
/******/ 	// Object.prototype.hasOwnProperty.call
/******/ 	__webpack_require__.o = function(object, property) { return Object.prototype.hasOwnProperty.call(object, property); };
/******/
/******/ 	// __webpack_public_path__
/******/ 	__webpack_require__.p = "";
/******/
/******/
/******/ 	// Load entry module and return exports
/******/ 	return __webpack_require__(__webpack_require__.s = 1);
/******/ })
/************************************************************************/
/******/ ([
/* 0 */,
/* 1 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

var dictCSSKeys = {
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
    "max-height": 17
};
var dictCSSValues = {
    absolute: "_1",
    unset: "_2",
    start: "_3"
};

var _Element = function () {
    function _Element(hashCode, controller, tag) {
        _classCallCheck(this, _Element);

        this.hashCode = hashCode;
        this.controller = controller;
        this.tag = tag;
        this.currentStyle = {};
        this.attributes = {};
        this.nodes = [];
        this.nodesHash = [];
        global.miniDomEventHandlers = _Element.eventHandlers;
    }

    _Element.prototype.setClass = function setClass(value) {
        if (this.class === value) return;
        this.class = value !== null && value !== void 0 ? value : "";
        this.setAttribute("class", value !== null && value !== void 0 ? value : "");
    };

    _Element.prototype.cloneNode = function cloneNode() {
        var deep = arguments.length > 0 && arguments[0] !== undefined ? arguments[0] : false;

        var clonedElement = this.controller.document.createElement(this.tag);
        clonedElement.setStyle(this.currentStyle);
        for (var key in this.attributes) {
            clonedElement.setAttribute(key, this.attributes[key]);
        }
        if (deep) {
            this.nodes.forEach(function (it) {
                clonedElement.appendChild(it.cloneNode(true));
            });
        }
        return clonedElement;
    };

    _Element.prototype.mpCloneNode = function mpCloneNode() {
        var clonedElement = this.controller.document.createElement(this.tag);
        clonedElement.setStyle(this.currentStyle);
        for (var key in this.attributes) {
            clonedElement.setAttribute(key, this.attributes[key]);
        }
        clonedElement.setChildrenLight(this.nodes);
        return clonedElement;
    };

    _Element.prototype.setTag = function setTag(value) {
        this.tag = value;
        this.controller.pushCommand(this.hashCode + ".tag", value);
    };

    _Element.prototype.setStyle = function setStyle(style) {
        var changed = false;
        var changeCount = 0;
        var changeKey = undefined;
        for (var key in style) {
            if (this.currentStyle[key] !== style[key]) {
                this.currentStyle[key] = style[key];
                changed = true;
                changeCount++;
                changeKey = key;
            }
        }
        if (changed && changeCount > 1) {
            this.controller.pushCommand(this.hashCode + ".s", this.transformStyle(this.currentStyle));
        } else if (changed && changeCount === 1) {
            var cssKey = this.toCSSKey(changeKey);
            if (dictCSSKeys[cssKey]) {
                this.controller.pushCommand(this.hashCode + ".s." + dictCSSKeys[cssKey], this.transformCSSValue(this.currentStyle[changeKey]));
            } else {
                var transformedStyle = this.transformStyle(this.currentStyle);
                this.controller.pushCommand(this.hashCode + ".s.other", transformedStyle["other"]);
            }
        }
    };

    _Element.prototype.transformStyle = function transformStyle(style) {
        var output = {};
        for (var key in style) {
            var cssKey = this.toCSSKey(key);
            if (dictCSSKeys[cssKey]) {
                output[dictCSSKeys[cssKey]] = this.transformCSSValue(style[key]);
            } else {
                if (!output["other"]) output["other"] = "";
                output["other"] += this.toCSSKey(key) + ":" + style[key] + ";";
            }
        }
        return output;
    };

    _Element.prototype.transformCSSValue = function transformCSSValue(value) {
        var _a;
        return (_a = dictCSSValues[value]) !== null && _a !== void 0 ? _a : value;
    };

    _Element.prototype.setAttribute = function setAttribute(name, value) {
        this.attributes[name] = value;
        this.controller.pushCommand(this.hashCode + "." + name, value);
    };

    _Element.prototype.removeAttribute = function removeAttribute(name) {
        delete this.attributes[name];
        this.controller.pushCommand(this.hashCode + "." + name, undefined);
    };

    _Element.prototype.insertBefore = function insertBefore(newChild, refChild) {
        var refIndex = refChild ? this.nodes.indexOf(refChild) : -1;
        if (refIndex >= 0) {
            if (newChild.parent) {
                newChild.parent.removeChild(newChild);
            }
            newChild.parent = this;
            this.nodes.splice(refIndex, 0, newChild);
            this.nodesHash.splice(refIndex, 0, newChild.hashCode);
            this.controller.pushCommand(this.hashCode + ".n", this.nodesHash);
        } else {
            this.appendChild(newChild);
        }
    };

    _Element.prototype.setChildrenLight = function setChildrenLight(children) {
        this.nodes = children;
        this.nodesHash = children.map(function (it) {
            return it.hashCode;
        });
        return this.controller.pushCommand(this.hashCode + ".n", this.nodesHash);
    };

    _Element.prototype.appendChild = function appendChild(child) {
        if (child.parent) {
            child.parent.removeChild(child);
        }
        child.parent = this;
        this.nodes.push(child);
        this.nodesHash.push(child.hashCode);
        return this.controller.pushCommand(this.hashCode + ".n", this.nodesHash);
    };

    _Element.prototype.removeChild = function removeChild(child) {
        var refIndex = this.nodes.indexOf(child);
        if (refIndex >= 0) {
            child.parent = undefined;
            this.nodes.splice(refIndex, 1);
            this.nodesHash.splice(refIndex, 1);
            this.controller.pushCommand(this.hashCode + ".n", this.nodesHash);
        }
    };

    _Element.prototype.remove = function remove() {
        if (this.parent) {
            this.parent.removeChild(this);
        }
    };

    _Element.prototype.getBoundingClientRect = function getBoundingClientRect() {
        var _this = this;

        if (this.class) {
            return this.getBoundingClientRectWithClass();
        }
        return new Promise(function (res) {
            wx.createSelectorQuery().in(_this.controller.componentInstance.selectComponent("#renderer")).select("#d_" + _this.hashCode).boundingClientRect(function (result) {
                res(result);
            }).exec();
        });
    };

    _Element.prototype.getBoundingClientRectWithClass = function getBoundingClientRectWithClass() {
        var _this2 = this;

        if (!_Element.classBoundingClientRectQuery[this.class]) {
            _Element.classBoundingClientRectQuery[this.class] = wx.createSelectorQuery().in(this.controller.componentInstance.selectComponent("#renderer")).selectAll("." + this.class).boundingClientRect(function (result) {
                if (result instanceof Array) {
                    result.forEach(function (it) {
                        var _a, _b;
                        (_b = (_a = _Element.classBoundingClientRectCallback)[it.id]) === null || _b === void 0 ? void 0 : _b.call(_a, {
                            width: it.width,
                            height: it.height
                        });
                        delete _Element.classBoundingClientRectCallback[it.id];
                    });
                }
            });
            setTimeout(function () {
                _Element.classBoundingClientRectQuery[_this2.class].exec();
                delete _Element.classBoundingClientRectQuery[_this2.class];
            }, 16);
        }
        return new Promise(function (res) {
            _Element.classBoundingClientRectCallback["d_" + _this2.hashCode] = res;
        });
    };

    _Element.prototype.getFields = function getFields(fields) {
        var _this3 = this;

        return new Promise(function (res) {
            wx.createSelectorQuery().in(_this3.controller.componentInstance.selectComponent("#renderer")).select("#d_" + _this3.hashCode).fields(fields).exec(function (result) {
                res(result[0]);
            });
        });
    };

    _Element.prototype.toCSSKey = function toCSSKey(str) {
        if (_Element.toCSSKeyCache[str]) return _Element.toCSSKeyCache[str];
        var snakeCase = str.replace(/[A-Z]/g, function (letter) {
            return "-" + letter.toLowerCase();
        });
        if (snakeCase.startsWith("webkit")) {
            snakeCase = "-" + snakeCase;
        }
        _Element.toCSSKeyCache[str] = snakeCase;
        return snakeCase;
    };

    _createClass(_Element, [{
        key: "firstChild",
        get: function get() {
            return this.nodes[0];
        }
    }, {
        key: "clientWidth",
        get: function get() {
            return wx.getSystemInfoSync().windowWidth;
        }
    }, {
        key: "clientHeight",
        get: function get() {
            return wx.getSystemInfoSync().windowHeight;
        }
    }, {
        key: "windowPaddingTop",
        get: function get() {
            return wx.getSystemInfoSync().statusBarHeight;
        }
    }, {
        key: "windowPaddingBottom",
        get: function get() {
            var _a, _b;
            return (_b = (_a = wx.getSystemInfoSync().safeArea) === null || _a === void 0 ? void 0 : _a.bottom) !== null && _b !== void 0 ? _b : 0;
        }
    }, {
        key: "devicePixelRatio",
        get: function get() {
            return wx.getSystemInfoSync().pixelRatio;
        }
    }, {
        key: "onclick",
        set: function set(value) {
            _Element.eventHandlers[this.hashCode + ".onclick"] = value;
            this.controller.pushCommand(this.hashCode + ".onclick", value ? this.hashCode : undefined);
        }
    }, {
        key: "oninput",
        set: function set(value) {
            _Element.eventHandlers[this.hashCode + ".oninput"] = value;
        }
    }, {
        key: "onsubmit",
        set: function set(value) {
            _Element.eventHandlers[this.hashCode + ".onsubmit"] = value;
        }
    }]);

    return _Element;
}();

_Element.eventHandlers = {};
_Element.classBoundingClientRectQuery = {};
_Element.classBoundingClientRectCallback = {};
_Element.toCSSKeyCache = {};

var _Document = function () {
    function _Document(controller) {
        _classCallCheck(this, _Document);

        this.controller = controller;
        this.body = new _Element("body", this.controller, "div");
    }

    _Document.prototype.createElement = function createElement(tag) {
        var hashCode = _Document.nextElementHashCode.toString();
        _Document.nextElementHashCode++;
        if (tag !== "div") {
            this.controller.pushCommand(hashCode, { id: hashCode, tag: tag });
        } else {
            this.controller.pushCommand(hashCode, { id: hashCode });
        }
        return new _Element(hashCode, this.controller, tag);
    };

    _Document.prototype.awaitSetState = function awaitSetState() {
        var _this4 = this;

        return new Promise(function (res) {
            _this4.controller.commandPromises.push(res);
        });
    };

    return _Document;
}();

_Document.nextElementHashCode = 0;

var MiniDom = function () {
    function MiniDom() {
        _classCallCheck(this, MiniDom);

        this.document = new _Document(this);
        this.commands = [];
        this.commandPromises = [];
        this.needsSetData = false;
    }

    MiniDom.prototype.markNeedsSetData = function markNeedsSetData() {
        var _this5 = this;

        if (this.needsSetData) return;
        this.needsSetData = true;
        setTimeout(function () {
            var data = {};
            _this5.commands.forEach(function (command) {
                var myKey = "";
                var parentKey = function () {
                    var k = command.key.split(".");
                    myKey = k.pop();
                    return k.join(".");
                }();
                if (data["dom." + parentKey]) {
                    data["dom." + parentKey][myKey] = command.value;
                } else if (parentKey.endsWith(".s") && data["dom." + parentKey.replace(".s", "")] && data["dom." + parentKey.replace(".s", "")]["s"]) {
                    data["dom." + parentKey.replace(".s", "")]["s"][myKey] = command.value;
                } else {
                    data["dom." + command.key] = command.value;
                }
            });
            // console.log("start set data", new Date().getTime());
            // const a = new Date().getTime();
            _this5.setData(data);
            // const b = new Date().getTime();
            // console.log(
            //   new Date().getTime(),
            //   "setdata",
            //   b - a,
            //   JSON.parse(JSON.stringify(data)),
            //   JSON.stringify(data).length
            // );
            // console.log("setdata", b - a);
            _this5.commandPromises.forEach(function (it) {
                return it(null);
            });
            _this5.commands = [];
            _this5.commandPromises = [];
            _this5.needsSetData = false;
        }, 16);
    };

    MiniDom.prototype.pushCommand = function pushCommand(key, value) {
        this.commands.push({ key: key, value: value });
        this.markNeedsSetData();
    };

    return MiniDom;
}();

Component({
    properties: {
        s: { type: String }
    },
    data: {
        dom: { body: { id: "body", tag: "div", s: "", n: [] } }
    },
    lifetimes: {
        attached: function attached() {
            this.miniDom = new MiniDom();
            this.miniDom.componentInstance = this;
            this.miniDom.setData = this.setData.bind(this);
        }
    }
});

/***/ })
/******/ ]);
//# sourceMappingURL=index.js.map