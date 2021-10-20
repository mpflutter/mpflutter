Component({
    properties: {
        dom: { type: Object },
        root: { type: String },
        style: { type: String },
    },
    data: {
        name: "renderer",
    },
    methods: {
        ontap: (event) => {
            var _a, _b;
            (_b = (_a = global.miniDomEventHandlers)[`${event.currentTarget.id.replace("d_", "")}.onclick`]) === null || _b === void 0 ? void 0 : _b.call(_a);
        },
        ontouchstart: (event) => {
            var _a, _b;
            (_b = (_a = global.miniDomEventHandlers)[`${event.currentTarget.id.replace("d_", "")}.ontouchstart`]) === null || _b === void 0 ? void 0 : _b.call(_a, event);
        },
        ontouchmove: (event) => {
            var _a, _b;
            (_b = (_a = global.miniDomEventHandlers)[`${event.currentTarget.id.replace("d_", "")}.ontouchmove`]) === null || _b === void 0 ? void 0 : _b.call(_a, event);
        },
        ontouchcancel: (event) => {
            var _a, _b;
            (_b = (_a = global.miniDomEventHandlers)[`${event.currentTarget.id.replace("d_", "")}.ontouchcancel`]) === null || _b === void 0 ? void 0 : _b.call(_a, event);
        },
        ontouchend: (event) => {
            var _a, _b;
            (_b = (_a = global.miniDomEventHandlers)[`${event.currentTarget.id.replace("d_", "")}.ontouchend`]) === null || _b === void 0 ? void 0 : _b.call(_a, event);
        },
        onTextInput: (event) => {
            var _a, _b;
            (_b = (_a = global.miniDomEventHandlers)[`${event.currentTarget.id.replace("d_", "")}.oninput`]) === null || _b === void 0 ? void 0 : _b.call(_a, event);
        },
        onTextSubmit: (event) => {
            var _a, _b;
            (_b = (_a = global.miniDomEventHandlers)[`${event.currentTarget.id.replace("d_", "")}.onsubmit`]) === null || _b === void 0 ? void 0 : _b.call(_a, event);
        },
        catchmove: (event) => { },
    },
});
