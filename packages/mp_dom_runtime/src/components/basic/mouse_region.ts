import { AncestorView, ComponentView } from "../component_view";
import { setDOMStyle } from "../dom_utils";

export class MouseRegion extends ComponentView {
  eventListened = false;

  setAttributes(attributes: any) {
    super.setAttributes(attributes);
    if (!this.eventListened) {
      this.eventListened = true;
      this.htmlElement.addEventListener("mouseenter", () => {
        this.engine.sendMessage(
          JSON.stringify({
            type: "mouse_region",
            message: {
              event: "onEnter",
              target: this.hashCode,
            },
          })
        );
      });
      this.htmlElement.addEventListener("mouseleave", () => {
        this.engine.sendMessage(
          JSON.stringify({
            type: "mouse_region",
            message: {
              event: "onExit",
              target: this.hashCode,
            },
          })
        );
      });
    }
    setDOMStyle(this.htmlElement, { cursor: this.cursor(attributes.cursor) });
  }

  cursor(value: string) {
    switch (value.replace("SystemMouseCursor", "")) {
      case "(click)":
        return "pointer";
      case "(none)":
        return "none";
      case "(basic)":
        return "default";
      case "(wait)":
        return "wait";
      case "(progress)":
        return "progress";
      case "(contextMenu)":
        return "context-menu";
      case "(help)":
        return "help";
      case "(text)":
        return "text";
      case "(verticalText)":
        return "vertical-text";
      case "(cell)":
        return "cell";
      case "(precise)":
        return "crosshair";
      case "(move)":
        return "move";
      case "(grab)":
        return "grab";
      case "(grabbing)":
        return "grabbing";
      case "(noDrop)":
        return "no-drop";
      case "(alias)":
        return "alias";
      case "(copy)":
        return "copy";
      case "(allScroll)":
        return "all-scroll";
      case "(resizeLeftRight)":
        return "ew-resize";
      case "(resizeUpDown)":
        return "ns-resize";
      case "(resizeUpLeftDownRight)":
        return "nwse-resize";
      case "(resizeUpRightDownLeft)":
        return "nesw-resize";
      case "(resizeUp)":
        return "n-resize";
      case "(resizeDown)":
        return "s-resize";
      case "(resizeLeft)":
        return "w-resize";
      case "(resizeRight)":
        return "e-resize";
      case "(resizeUpLeft)":
        return "nw-resize";
      case "(resizeUpRight)":
        return "ne-resize";
      case "(resizeDownLeft)":
        return "sw-resize";
      case "(resizeDownRight)":
        return "se-resize";
      case "(resizeColumn)":
        return "col-resize";
      case "(resizeRow)":
        return "row-resize";
      case "(zoomIn)":
        return "zoom-in";
      case "(zoomOut)":
        return "zoom-out";
      default:
        return "auto";
    }
  }
}
