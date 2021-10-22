let eventMap = {
    tap: "click",
    confirm: "submit",
};
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
        onEvent: (event) => {
            var _a, _b;
            (_a = global.miniDomEventHandlers[`${event.currentTarget.id.replace("d_", "")}`]) === null || _a === void 0 ? void 0 : _a.emit((_b = eventMap[event.type]) !== null && _b !== void 0 ? _b : event.type, event);
        },
    },
});
