import 'weui';
// import weui from 'weui.js';
export class MPPicker {
  private static currentPickerElement?: HTMLElement;

  static weuiShadowRoot: any;

  static showSinglePicker(options: {
    divElement: HTMLDivElement;
    itemList: string[];
    success: (res: { tapIndex: number }) => void;
    fail: () => void;
  }) {
    // const div = document.createElement("body");
    // div.style.position = "absolute";
    // div.style.width = "100%";
    // div.style.height = "100%";
    // div.innerHTML = `<div class="weui-btn weui-btn_default" id="showPicker">单列选择器</div>`;
    // div.ontouchmove = (e) => {
    //   e.preventDefault();
    // };
    // this.weuiShadowRoot.appendChild(div);
    options.divElement.onclick = () => {
      // weui;
      this.weuiShadowRoot.weui.picker([{
        label: '飞机票',
        value: 0
    }, {
        label: '火车票',
        value: 1
    }, {
        label: '的士票',
        value: 2
    },{
        label: '公交票 (disabled)',
        disabled: true,
        value: 3
    }, {
        label: '其他',
        value: 4
    }], {
        onChange: function () {
            console.log('result');
        },
        onConfirm: function () {
            console.log('result');
        },
        title: '单列选择器'
    });;
    };

    // const cells = div.getElementsByClassName("weui-btn weui-btn_default");
    // for (let index = 0; index < cells.length; index++) {
    //   const element = cells[index];
    //   (element as HTMLDivElement).onclick = () => {
    //     const dataIndex = element.getAttribute("data-index");
    //     if (dataIndex) {
    //       options.success?.({
    //         tapIndex: parseInt(dataIndex),
    //       });
    //     } else {
    //       options.fail?.();
    //     }
    //     div.remove();
    //   };
    // }
  }
}
