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

function _possibleConstructorReturn(self, call) { if (!self) { throw new ReferenceError("this hasn't been initialised - super() hasn't been called"); } return call && (typeof call === "object" || typeof call === "function") ? call : self; }

function _inherits(subClass, superClass) { if (typeof superClass !== "function" && superClass !== null) { throw new TypeError("Super expression must either be null or a function, not " + typeof superClass); } subClass.prototype = Object.create(superClass && superClass.prototype, { constructor: { value: subClass, enumerable: false, writable: true, configurable: true } }); if (superClass) Object.setPrototypeOf ? Object.setPrototypeOf(subClass, superClass) : subClass.__proto__ = superClass; }

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

var EventEmitter = __webpack_require__(2);
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

var _ClassList = function () {
    function _ClassList(element) {
        _classCallCheck(this, _ClassList);

        this.element = element;
        this.value = [];
    }

    _ClassList.prototype.add = function add(v) {
        if (this.value.indexOf(v) < 0) {
            this.value.push(v);
            this.element.setAttribute("class", this.value.join(" "));
        }
    };

    _ClassList.prototype.remove = function remove(v) {
        var idx = this.value.indexOf(v);
        if (idx >= 0) {
            this.value.splice(idx, 1);
            this.element.setAttribute("class", this.value.join(" "));
        }
    };

    _ClassList.prototype.toggle = function toggle(v) {
        var idx = this.value.indexOf(v);
        if (idx >= 0) {
            this.value.splice(idx, 1);
        } else {
            this.value.push(v);
        }
        this.element.setAttribute("class", this.value.join(" "));
    };

    return _ClassList;
}();

var _Element = function (_EventEmitter) {
    _inherits(_Element, _EventEmitter);

    function _Element(hashCode, controller, tag) {
        _classCallCheck(this, _Element);

        var _this = _possibleConstructorReturn(this, _EventEmitter.call(this));

        _this.hashCode = hashCode;
        _this.controller = controller;
        _this.tag = tag;
        _this.classList = new _ClassList(_this);
        _this.attributes = {};
        _this.nodes = [];
        _this.nodesHash = [];
        _this.style = new Proxy({}, {
            set: function set(obj, prop, value) {
                if (obj[prop] === value) return true;
                obj[prop] = value;
                _this.controller.pushCommand(_this.hashCode + ".s", _this.transformStyle(obj));
                return true;
            }
        });
        global.miniDomEventHandlers = _Element.eventHandlers;
        return _this;
    }

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
        var _this2 = this;

        if (this.classList.value.length > 0) {
            return this.getBoundingClientRectWithClass();
        }
        var targetComponent = this.controller.componentInstance.selectComponent("#renderer").getComponent(this.hashCode);
        if (!targetComponent) {
            targetComponent = this.controller.componentInstance.selectComponent("#renderer");
        }
        return new Promise(function (res) {
            wx.createSelectorQuery().in(targetComponent).select("#d_" + _this2.hashCode).boundingClientRect(function (result) {
                res(result);
            }).exec();
        });
    };

    _Element.prototype.getBoundingClientRectWithClass = function getBoundingClientRectWithClass() {
        var _this3 = this;

        var className = this.classList.value[0];
        if (!_Element.classBoundingClientRectQuery[className]) {
            _Element.classBoundingClientRectQuery[className] = wx.createSelectorQuery().in(this.controller.componentInstance.selectComponent("#renderer")).selectAll("." + className).boundingClientRect(function (result) {
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
                _Element.classBoundingClientRectQuery[className].exec();
                delete _Element.classBoundingClientRectQuery[className];
            }, 16);
        }
        return new Promise(function (res) {
            _Element.classBoundingClientRectCallback["d_" + _this3.hashCode] = res;
        });
    };

    _Element.prototype.getFields = function getFields(fields) {
        var _this4 = this;

        return new Promise(function (res) {
            var targetComponent = _this4.controller.componentInstance.selectComponent("#renderer").getComponent(_this4.hashCode);
            if (!targetComponent) {
                targetComponent = _this4.controller.componentInstance.selectComponent("#renderer");
            }
            wx.createSelectorQuery().in(targetComponent).select("#d_" + _this4.hashCode).fields(fields).exec(function (result) {
                res(result[0]);
            });
        });
    };

    _Element.prototype.addEventListener = function addEventListener(event, callback) {
        _Element.eventHandlers["" + this.hashCode] = this;
        this.controller.pushCommand(this.hashCode + "." + event, true);
        this.on(event, callback);
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
    }]);

    return _Element;
}(EventEmitter);

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
        var _this5 = this;

        return new Promise(function (res) {
            _this5.controller.commandPromises.push(res);
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
        this.commandsKeyPosition = {};
        this.commandPromises = [];
        this.needsSetData = false;
    }

    MiniDom.prototype.markNeedsSetData = function markNeedsSetData() {
        var _this6 = this;

        if (this.needsSetData) return;
        this.needsSetData = true;
        setTimeout(function () {
            var data = {};
            _this6.commands.forEach(function (command) {
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
            _this6.setData(data);
            // const b = new Date().getTime();
            // console.log(
            //   new Date().getTime(),
            //   "setdata",
            //   b - a,
            //   JSON.parse(JSON.stringify(data)),
            //   JSON.stringify(data).length
            // );
            // console.log("setdata", b - a);
            _this6.commandPromises.forEach(function (it) {
                return it(null);
            });
            _this6.commands = [];
            _this6.commandsKeyPosition = {};
            _this6.commandPromises = [];
            _this6.needsSetData = false;
        }, 4);
    };

    MiniDom.prototype.pushCommand = function pushCommand(key, value) {
        var position = this.commands.length;
        if (this.commandsKeyPosition[key] !== undefined) {
            this.commands[this.commandsKeyPosition[key]] = { key: key, value: value };
        } else {
            this.commands.push({ key: key, value: value });
            this.commandsKeyPosition[key] = position;
        }
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
            var _this7 = this;

            this.miniDom = new MiniDom();
            this.miniDom.componentInstance = this;
            this.miniDom.setData = function (data) {
                _this7.selectComponent("#renderer").doSetData(data);
            };
        }
    }
});

/***/ }),
/* 2 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";
var __WEBPACK_AMD_DEFINE_FACTORY__, __WEBPACK_AMD_DEFINE_ARRAY__, __WEBPACK_AMD_DEFINE_RESULT__;var require;var require;

var _typeof = typeof Symbol === "function" && typeof Symbol.iterator === "symbol" ? function (obj) { return typeof obj; } : function (obj) { return obj && typeof Symbol === "function" && obj.constructor === Symbol && obj !== Symbol.prototype ? "symbol" : typeof obj; };

!function (e) {
  "object" == ( false ? undefined : _typeof(exports)) && "undefined" != typeof module ? module.exports = e() :  true ? !(__WEBPACK_AMD_DEFINE_ARRAY__ = [], __WEBPACK_AMD_DEFINE_FACTORY__ = (e),
				__WEBPACK_AMD_DEFINE_RESULT__ = (typeof __WEBPACK_AMD_DEFINE_FACTORY__ === 'function' ?
				(__WEBPACK_AMD_DEFINE_FACTORY__.apply(exports, __WEBPACK_AMD_DEFINE_ARRAY__)) : __WEBPACK_AMD_DEFINE_FACTORY__),
				__WEBPACK_AMD_DEFINE_RESULT__ !== undefined && (module.exports = __WEBPACK_AMD_DEFINE_RESULT__)) : undefined;
}(function () {
  return function i(s, f, c) {
    function u(t, e) {
      if (!f[t]) {
        if (!s[t]) {
          var n = "function" == typeof require && require;if (!e && n) return require(t, !0);if (a) return a(t, !0);var r = new Error("Cannot find module '" + t + "'");throw r.code = "MODULE_NOT_FOUND", r;
        }var o = f[t] = { exports: {} };s[t][0].call(o.exports, function (e) {
          return u(s[t][1][e] || e);
        }, o, o.exports, i, s, f, c);
      }return f[t].exports;
    }for (var a = "function" == typeof require && require, e = 0; e < c.length; e++) {
      u(c[e]);
    }return u;
  }({ 1: [function (e, t, n) {
      "use strict";
      var r = Object.prototype.hasOwnProperty,
          v = "~";function o() {}function f(e, t, n) {
        this.fn = e, this.context = t, this.once = n || !1;
      }function i(e, t, n, r, o) {
        if ("function" != typeof n) throw new TypeError("The listener must be a function");var i = new f(n, r || e, o),
            s = v ? v + t : t;return e._events[s] ? e._events[s].fn ? e._events[s] = [e._events[s], i] : e._events[s].push(i) : (e._events[s] = i, e._eventsCount++), e;
      }function u(e, t) {
        0 == --e._eventsCount ? e._events = new o() : delete e._events[t];
      }function s() {
        this._events = new o(), this._eventsCount = 0;
      }Object.create && (o.prototype = Object.create(null), new o().__proto__ || (v = !1)), s.prototype.eventNames = function () {
        var e,
            t,
            n = [];if (0 === this._eventsCount) return n;for (t in e = this._events) {
          r.call(e, t) && n.push(v ? t.slice(1) : t);
        }return Object.getOwnPropertySymbols ? n.concat(Object.getOwnPropertySymbols(e)) : n;
      }, s.prototype.listeners = function (e) {
        var t = v ? v + e : e,
            n = this._events[t];if (!n) return [];if (n.fn) return [n.fn];for (var r = 0, o = n.length, i = new Array(o); r < o; r++) {
          i[r] = n[r].fn;
        }return i;
      }, s.prototype.listenerCount = function (e) {
        var t = v ? v + e : e,
            n = this._events[t];return n ? n.fn ? 1 : n.length : 0;
      }, s.prototype.emit = function (e, t, n, r, o, i) {
        var s = v ? v + e : e;if (!this._events[s]) return !1;var f,
            c = this._events[s],
            u = arguments.length;if (c.fn) {
          switch (c.once && this.removeListener(e, c.fn, void 0, !0), u) {case 1:
              return c.fn.call(c.context), !0;case 2:
              return c.fn.call(c.context, t), !0;case 3:
              return c.fn.call(c.context, t, n), !0;case 4:
              return c.fn.call(c.context, t, n, r), !0;case 5:
              return c.fn.call(c.context, t, n, r, o), !0;case 6:
              return c.fn.call(c.context, t, n, r, o, i), !0;}for (p = 1, f = new Array(u - 1); p < u; p++) {
            f[p - 1] = arguments[p];
          }c.fn.apply(c.context, f);
        } else for (var a, l = c.length, p = 0; p < l; p++) {
          switch (c[p].once && this.removeListener(e, c[p].fn, void 0, !0), u) {case 1:
              c[p].fn.call(c[p].context);break;case 2:
              c[p].fn.call(c[p].context, t);break;case 3:
              c[p].fn.call(c[p].context, t, n);break;case 4:
              c[p].fn.call(c[p].context, t, n, r);break;default:
              if (!f) for (a = 1, f = new Array(u - 1); a < u; a++) {
                f[a - 1] = arguments[a];
              }c[p].fn.apply(c[p].context, f);}
        }return !0;
      }, s.prototype.on = function (e, t, n) {
        return i(this, e, t, n, !1);
      }, s.prototype.once = function (e, t, n) {
        return i(this, e, t, n, !0);
      }, s.prototype.removeListener = function (e, t, n, r) {
        var o = v ? v + e : e;if (!this._events[o]) return this;if (!t) return u(this, o), this;var i = this._events[o];if (i.fn) i.fn !== t || r && !i.once || n && i.context !== n || u(this, o);else {
          for (var s = 0, f = [], c = i.length; s < c; s++) {
            (i[s].fn !== t || r && !i[s].once || n && i[s].context !== n) && f.push(i[s]);
          }f.length ? this._events[o] = 1 === f.length ? f[0] : f : u(this, o);
        }return this;
      }, s.prototype.removeAllListeners = function (e) {
        var t;return e ? (t = v ? v + e : e, this._events[t] && u(this, t)) : (this._events = new o(), this._eventsCount = 0), this;
      }, s.prototype.off = s.prototype.removeListener, s.prototype.addListener = s.prototype.on, s.prefixed = v, s.EventEmitter = s, void 0 !== t && (t.exports = s);
    }, {}] }, {}, [1])(1);
});

/***/ })
/******/ ]);
//# sourceMappingURL=index.js.map