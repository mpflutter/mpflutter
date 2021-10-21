let eventMap = {
  tap: "click",
  confirm: "submit",
};

Component({
  properties: {
    root: { type: String },
    style: { type: String },
  },
  data: {
    name: "renderer",
    dom: { body: { id: "body", tag: "div", s: "", n: [] } },
  },
  methods: {
    onEvent: (event) => {
      global.miniDomEventHandlers[`${event.currentTarget.id.replace("d_", "")}`]?.emit(
        eventMap[event.type] ?? event.type,
        event
      );
    },
    filterIndexes: function (dom, targetIndex) {
      let result = [];
      if (dom[targetIndex] && dom[targetIndex].n) {
        result.push(...dom[targetIndex].n);
        dom[targetIndex].n.forEach((it) => {
          result.push(...this.filterIndexes(dom, it));
        });
      }
      return result;
    },
    filterData: function (data, targetIndexes) {
      let result = {};
      let targetIndexMap = {};
      targetIndexes.forEach((it) => {
        targetIndexMap["dom." + it] = true;
      });
      for (let key in data) {
        let split = key.split(".");
        let prefixKey = `${split[0]}.${split[1]}`;
        if (targetIndexMap[prefixKey] === true) {
          result[key] = data[key];
        }
      }
      return result;
    },
    doSetData: function (data, dom) {
      this.setData(data);
      this.selectAllComponents(".renderer").forEach((component) => {
        const targetIndexes = [component.data.root];
        targetIndexes.push(...this.filterIndexes(dom ?? this.data.dom, component.data.root));
        component.doSetData(this.filterData(data, targetIndexes), dom ?? this.data.dom);
      });
    },
  },
});
