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
/******/ 	return __webpack_require__(__webpack_require__.s = 0);
/******/ })
/************************************************************************/
/******/ ([
/* 0 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


var eventMap = {
    tap: "click",
    confirm: "submit"
};
Component({
    properties: {
        root: { type: String },
        style: { type: String }
    },
    data: {
        name: "renderer",
        dom: { body: { id: "body", tag: "div", s: "", n: [] } }
    },
    methods: {
        onEvent: function onEvent(event) {
            var _a, _b;
            (_a = global.miniDomEventHandlers["" + event.currentTarget.id.replace("d_", "")]) === null || _a === void 0 ? void 0 : _a.emit((_b = eventMap[event.type]) !== null && _b !== void 0 ? _b : event.type, event);
        },
        filterIndexes: function filterIndexes(dom, targetIndex) {
            var _this = this;

            var result = [];
            if (dom[targetIndex] && dom[targetIndex].n) {
                result.push.apply(result, dom[targetIndex].n);
                dom[targetIndex].n.forEach(function (it) {
                    result.push.apply(result, _this.filterIndexes(dom, it));
                });
            }
            return result;
        },
        filterData: function filterData(data, targetIndexes) {
            var result = {};
            var targetIndexMap = {};
            targetIndexes.forEach(function (it) {
                targetIndexMap["dom." + it] = true;
            });
            for (var key in data) {
                var split = key.split(".");
                var prefixKey = split[0] + "." + split[1];
                if (targetIndexMap[prefixKey] === true) {
                    result[key] = data[key];
                }
            }
            return result;
        },
        getComponent: function getComponent(target) {
            var targetComponent = void 0;
            this.selectAllComponents(".renderer").forEach(function (component) {
                if (targetComponent) return;
                if (component.targetIndexes && component.targetIndexes.indexOf(target) >= 0) {
                    targetComponent = component;
                } else {
                    var nextTargetComponent = component.getComponent(target);
                    if (nextTargetComponent) {
                        targetComponent = nextTargetComponent;
                    }
                }
            });
            return targetComponent;
        },
        doSetData: function doSetData(data, dom) {
            var _this2 = this;

            this.setData(data);
            this.selectAllComponents(".renderer").forEach(function (component) {
                var targetIndexes = [component.data.root];
                targetIndexes.push.apply(targetIndexes, _this2.filterIndexes(dom !== null && dom !== void 0 ? dom : _this2.data.dom, component.data.root));
                component.targetIndexes = targetIndexes;
                component.doSetData(_this2.filterData(data, targetIndexes), dom !== null && dom !== void 0 ? dom : _this2.data.dom);
            });
        }
    }
});

/***/ })
/******/ ]);
//# sourceMappingURL=renderer.js.map