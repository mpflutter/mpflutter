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
      global.miniDomEventHandlers[`${event.currentTarget.id.replace("d_", "")}.onclick`]?.();
    },
    ontouchstart: (event) => {
      global.miniDomEventHandlers[`${event.currentTarget.id.replace("d_", "")}.ontouchstart`]?.(event);
    },
    ontouchmove: (event) => {
      global.miniDomEventHandlers[`${event.currentTarget.id.replace("d_", "")}.ontouchmove`]?.(event);
    },
    ontouchcancel: (event) => {
      global.miniDomEventHandlers[`${event.currentTarget.id.replace("d_", "")}.ontouchcancel`]?.(event);
    },
    ontouchend: (event) => {
      global.miniDomEventHandlers[`${event.currentTarget.id.replace("d_", "")}.ontouchend`]?.(event);
    },
    onTextInput: (event) => {
      global.miniDomEventHandlers[`${event.currentTarget.id.replace("d_", "")}.oninput`]?.(event);
    },
    onTextSubmit: (event) => {
      global.miniDomEventHandlers[`${event.currentTarget.id.replace("d_", "")}.onsubmit`]?.(event);
    },
    onButtonCallback: (event) => {
      global.miniDomEventHandlers[`${event.currentTarget.id.replace("d_", "")}.onbuttoncallback`]?.(
        JSON.stringify({
          detail: event.detail,
          type: event.type,
        })
      );
    },
    catchmove: (event) => {},
  },
});
