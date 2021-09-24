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
    onTextInput: (event) => {
      global.miniDomEventHandlers[`${event.currentTarget.id.replace("d_", "")}.oninput`]?.(event);
    },
    onTextSubmit: (event) => {
      global.miniDomEventHandlers[`${event.currentTarget.id.replace("d_", "")}.onsubmit`]?.(event);
    },
    catchmove: (event) => {},
  },
});
