export class MPWebPicker {
  static weuiShadowRoot: any;

  static showSinglePicker(options: {
    title: string;
    itemList: string[];
    success: (res: { tapIndex: number }) => void;
  }) {
    this.weuiShadowRoot.weui.picker(
      options.itemList.map((it, idx) => {
        return {
          label: it,
          value: idx,
        };
      }),
      {
        onChange: function (result: any) {
          options.success?.({
            tapIndex: parseInt(result.value),
          });
        },
        onConfirm: function (result: any) {
          options.success?.({
            tapIndex: parseInt(result.value),
          });
        },
        title: options.title,
      }
    );
  }
}
