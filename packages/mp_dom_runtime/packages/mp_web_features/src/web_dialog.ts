export class MPWebDialog {
  private static currentToastElement?: HTMLElement;
  private static currentToastHandler?: any;

  static weuiShadowRoot: any;

  static showToast(options: { title: string; icon: string; duration: number; mask: boolean }) {
    if (this.currentToastElement) {
      this.currentToastElement.remove();
      this.currentToastElement = undefined;
    }
    if (this.currentToastHandler) {
      clearTimeout(this.currentToastHandler);
      this.currentToastHandler = undefined;
    }
    const div = document.createElement("body");
    div.style.position = "absolute";
    div.style.width = "100%";
    div.style.height = "100%";
    div.innerHTML = `<div class="weui-mask_transparent"></div>
    <div class="weui-toast${options.icon === "none" ? " weui-toast_text" : ""}">
        ${options.icon === "none" ? `` : `<span class="${this.toastIcon(options.icon)} weui-icon_toast"></span>`}
        <p class="weui-toast__content">${options.title}</p>
    </div>`;
    if (options.mask === true) {
      div.ontouchmove = (e) => {
        e.preventDefault();
      };
    }
    this.weuiShadowRoot.appendChild(div);
    this.currentToastElement = div;
    this.currentToastHandler = setTimeout(() => {
      div.remove();
    }, options.duration);
  }

  static toastIcon(value: string) {
    switch (value) {
      case "error":
        return "weui-icon-warn";
      case "loading":
        return "weui-primary-loading";
      case "success":
        return "weui-icon-success-no-circle";
    }
  }

  static hideToast() {
    if (this.currentToastElement) {
      this.currentToastElement.remove();
      this.currentToastElement = undefined;
    }
    if (this.currentToastHandler) {
      clearTimeout(this.currentToastHandler);
      this.currentToastHandler = undefined;
    }
  }

  static showActionSheet(options: {
    itemList: string[];
    success: (res: { tapIndex: number }) => void;
    fail: () => void;
  }) {
    const div = document.createElement("body");
    div.style.position = "absolute";
    div.style.width = "100%";
    div.style.height = "100%";
    div.innerHTML = `<div class="weui-mask" id="iosMask"></div>
    <div class="weui-actionsheet weui-actionsheet_toggle" id="iosActionsheet" style="z-index:10002;">
        <div class="weui-actionsheet__menu">
            ${options.itemList
              .map((it, idx) => `<div data-index="${idx}" class="weui-actionsheet__cell">${it}</div>`)
              .join("")}
        </div>
        <div class="weui-actionsheet__action">
            <div class="weui-actionsheet__cell" id="iosActionsheetCancel">取消</div>
        </div>
    </div>`;
    div.ontouchmove = (e) => {
      e.preventDefault();
    };
    this.weuiShadowRoot.appendChild(div);
    const cells = div.getElementsByClassName("weui-actionsheet__cell");
    for (let index = 0; index < cells.length; index++) {
      const element = cells[index];
      (element as HTMLDivElement).onclick = () => {
        const dataIndex = element.getAttribute("data-index");
        if (dataIndex) {
          options.success?.({
            tapIndex: parseInt(dataIndex),
          });
        } else {
          options.fail?.();
        }
        div.remove();
      };
    }
  }

  static showSinglePicker(options: {
    title: string;
    itemList: string[];
    success: (res: { tapIndex: number }) => void;
  }) {
    const div = document.createElement("body");
    div.style.position = "absolute";
    div.style.width = "100%";
    div.style.height = "100%";
    div.innerHTML = `<div class="weui-mask" id="iosMask"></div>
    <div class="">
        <div class="weui-mask weui-animate-fade-in"></div>
        <div class="weui-half-screen-dialog weui-picker weui-animate-slide-up">
            <div class="weui-half-screen-dialog__hd">
                <div class="weui-half-screen-dialog__hd__side">
                    <button class="weui-icon-btn weui-icon-btn_close weui-picker__btn">关闭</button>
                </div>
                <div class="weui-half-screen-dialog__hd__main">
                    <strong class="weui-half-screen-dialog__title">${options.title}</strong>
                </div>
            </div>
            <div class="weui-half-screen-dialog__bd">
                <div class="weui-picker__bd">
                    <div class="weui-picker__group">
                        <div class="weui-picker__mask"></div>
                        <div class="weui-picker__indicator"></div>
                        <div class="weui-picker__content" style="transform: translate3d(0px, 0px, 0px);">
                            ${options.itemList
                              .map((it, idx) => `<div data-index="${idx}" class="weui-picker__item">${it}</div>`)
                              .join("")}
                        </div>
                    </div>
                </div>
            </div>
            <div class="weui-half-screen-dialog__ft">
                <a href="javascript:;" class="weui-btn weui-btn_primary weui-picker__btn" id="weui-picker-confirm" data-action="select">确定</a>
            </div>
          </div>
    </div>
    `;
    div.style.overflow = 'auto';
    div.ontouchmove = (e) => {
      e.preventDefault();
    };
    this.weuiShadowRoot.appendChild(div);
    // (window as any).weui.picker(
    //   options.itemList.map((it, idx) => {
    //     return {
    //       label: it,
    //       value: idx,
    //     };
    //   }),
    //   {
    //     onChange: function (result: any) {
    //       options.success?.({
    //         tapIndex: parseInt(result.value),
    //       });
    //     },
    //     onConfirm: function (result: any) {
    //       options.success?.({
    //         tapIndex: parseInt(result.value),
    //       });
    //       div.remove();
    //     },
    //     title: options.title,
    //   },
    // );
  }
}
