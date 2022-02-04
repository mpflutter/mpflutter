let MPJSWindow = self;
var MPJS = function() {
    let self;
    self = {
        objectRefs: {},
        handleMessage: function (message, callback, funcCallback) {
            var argCallback = callback;
            callback = function(value) {
                argCallback(JSON.stringify({value: value}));
            }
            var argFuncCallback = funcCallback;
            funcCallback = function(funcId, args) {
                argFuncCallback(JSON.stringify({funcId: funcId, arguments: args}));
            }
            if (message.event === "callMethod") {
                self.callMethod(message, callback, funcCallback);
            } else if (message.event === "getValue") {
                self.getValue(message, callback);
            } else if (message.event === "setValue") {
                self.setValue(message, callback);
            } else if (message.event === "hasProperty") {
                self.hasProperty(message, callback);
            } else if (message.event === "deleteProperty") {
                self.deleteProperty(message, callback);
            }
        },
        callMethod: function (
            message,
            callback,
            funcCallback
        ) {
            let params = message.params;
            let callingObject = self.getCallee(
                params.objectHandler,
                params.callChain
            );
            if (
                typeof callingObject === "object" ||
                typeof callingObject === "function"
            ) {
                try {
                    let result = (callingObject[params.method]).apply(
                        callingObject,
                        params.args?.map(function (it) { return self.wrapArgument(it, funcCallback); })
                    );
                    callback(self.wrapResult(result));
                } catch (error) {
                    console.error(error);
                }
            }
        },
        getValue: function (message, callback) {
            let params = message.params;
            let callingObject = self.getCallee(
                params.objectHandler,
                params.callChain
            );
            callback(self.wrapResult(callingObject[params.key]));
        },
        setValue: function (message, callback) {
            let params = message.params;
            let callingObject = self.getCallee(
                params.objectHandler,
                params.callChain
            );
            callingObject[params.key] = params.value;
            callback(undefined);
        },
        hasProperty: function (message, callback) {
            let params = message.params;
            let callingObject = self.getCallee(
                params.objectHandler,
                params.callChain
            );
            callback(self.wrapResult(callingObject && callingObject.hasOwnProperty(params.key)));
        },
        deleteProperty: function (message, callback) {
            let params = message.params;
            let callingObject = self.getCallee(
                params.objectHandler,
                params.callChain
            );
            if (callingObject) {
                delete callingObject[params.key];
            }
            callback(1);
        },
        getCallee: function (objectHandler, callChain) {
            let rootObject = self.objectRefs[objectHandler] ?? MPJSWindow;
            let currentObject = rootObject;
            for (let index = 0; index < callChain.length; index++) {
                let key = callChain[index];
                currentObject = currentObject[key];
                if (currentObject === undefined || currentObject === null) {
                    break;
                }
            }
            return currentObject;
        },
        wrapArgument: function (arg, funcCallback) {
            if (typeof arg === "string" && arg.startsWith("func:")) {
                let funcId = arg;
                let self = this;
                return function () {
                    let cbArgs = [];
                    for (let index = 0; index < arguments.length; index++) {
                        let element = arguments[index];
                        cbArgs.push(self.wrapResult(element));
                    }
                    funcCallback(funcId, cbArgs);
                };
            } else if (typeof arg === "string" && arg.startsWith("obj:")) {
                return self.objectRefs[arg.replace("obj:", "")];
            } else if (typeof arg === "object" && arg instanceof Array) {
                return arg.map(function (it) { return self.wrapArgument(it, funcCallback) });
            } else if (typeof arg === "object") {
                let newArgs = {};
                for (let key in arg) {
                    newArgs[key] = self.wrapArgument(arg[key], funcCallback);
                }
                return newArgs;
            } else {
                return arg;
            }
        },
        wrapResult: function (result) {
            if (
                typeof result === "string" ||
                typeof result === "number" ||
                typeof result === "boolean" ||
                typeof result === "bigint"
            ) {
                return result;
            } else {
                let objectHandler = Math.random().toString();
                self.objectRefs[objectHandler] = result;
                return { objectHandler: objectHandler };
            }
        }
    };
    return self;
};

MPJS.instance = new MPJS();
