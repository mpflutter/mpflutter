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
