import { MPEnv, PlatformType } from "../../env";
import { ComponentView } from "../component_view";
import { setDOMAttribute, setDOMStyle } from "../dom_utils";
import { cssTextAlign, cssTextStyle } from "../utils";

export class EditableText extends ComponentView {
  contentElement?: HTMLInputElement | HTMLTextAreaElement;
  contentElementType = "";

  setAttributes(attributes: any) {
    super.setAttributes(attributes);
    const maxLines = attributes.maxLines;

    if (maxLines > 1 && this.contentElementType !== "textarea") {
      this.contentElement?.remove();
      this.contentElement = this.document.createElement("textarea");
      setDOMStyle(this.contentElement, {
        width: "100%",
        height: "100%",
        backgroundColor: "transparent",
        border: "none",
        resize: "none",
      });
      this.htmlElement.appendChild(this.contentElement);
    } else if (maxLines <= 1 && this.contentElementType !== "input") {
      this.contentElement?.remove();
      this.contentElement = this.document.createElement("input");
      setDOMStyle(this.contentElement, {
        width: "100%",
        height: "100%",
        backgroundColor: "transparent",
        border: "none",
      });
      this.htmlElement.appendChild(this.contentElement);
    }
    if (!this.contentElement) return;
    this.contentElement.onkeyup = (event) => {
      if (event.key === "Enter" || event.keyCode === 13) {
        this._onSubmitted(
          event.target as HTMLInputElement,
          (event.target as HTMLInputElement).value
        );
      }
    };
    this.contentElement.onsubmit = (event: any) => {
      this._onSubmitted(
        event.target,
        event.detail?.value ?? (event.target as HTMLInputElement).value
      );
    };
    this.contentElement.oninput = (event: any) => {
      this._onChanged(
        event.target,
        event.detail?.value ?? (event.target as HTMLInputElement).value
      );
    };
    this.contentElement.onchange = (event: any) => {
      this._onChanged(
        event.target,
        event.detail?.value ?? (event.target as HTMLInputElement).value
      );
    };
    if (attributes.style) {
      let textStyle: any = cssTextStyle(attributes.style);
      delete textStyle["userSelect"];
      delete textStyle["WebkitUserSelect"];
      setDOMStyle(this.contentElement, {
        ...textStyle,
        textAlign: cssTextAlign(attributes.textAlign),
        boxSizing: "border-box",
      });
    }
    setDOMAttribute(
      this.contentElement,
      "type",
      attributes.obscureText
        ? "password"
        : this._keyboardType(attributes.keyboardType)
    );
    setDOMAttribute(
      this.contentElement,
      "pattern",
      this._keyboardPattern(attributes.keyboardType)
    );
    if (attributes.value) {
      if (
        MPEnv.platformType === PlatformType.wxMiniProgram ||
        MPEnv.platformType === PlatformType.swanMiniProgram
      ) {
        setDOMAttribute(this.contentElement, "value", attributes.value);
      } else {
        this.contentElement.value = attributes.value;
      }
    }
    if (attributes.autofocus) {
      setDOMAttribute(this.contentElement, "autoFocus", attributes.autofocus);
    }
    if (attributes.autoCorrect) {
      setDOMAttribute(
        this.contentElement,
        "autoCorrect",
        attributes.autoCorrect
      );
    }
    if (attributes.placeholder) {
      setDOMAttribute(
        this.contentElement,
        "placeholder",
        attributes.placeholder
      );
    }
    setDOMAttribute(
      this.contentElement,
      "readOnly",
      attributes.readOnly ? "true" : undefined
    );
  }

  setChildren() {}

  _keyboardType(value: string) {
    if (value?.indexOf("TextInputType.number") > 0) {
      return "number";
    }
    return "text";
  }

  _keyboardPattern(value: string) {
    if (value?.indexOf("TextInputType.number") > 0) {
      const signed = value.indexOf("signed: true") > 0;
      const decimal = value.indexOf("decimal: true") > 0;
      if (signed && decimal) {
        return "[0-9+-.]*";
      }
      if (signed && !decimal) {
        return "[0-9+-]*";
      }
      if (!signed && !decimal) {
        return "[0-9]*";
      }
    }
    return "";
  }

  _onSubmitted(target: HTMLInputElement, value: string) {
    if (this.attributes.onSubmitted) {
      this.engine.sendMessage(
        JSON.stringify({
          type: "editable_text",
          message: {
            event: "onSubmitted",
            target: this.attributes.onSubmitted,
            data: value,
          },
        })
      );
      target.blur();
    }
  }

  _onChanged(target: HTMLInputElement, value: string) {
    if (this.attributes.onChanged) {
      this.engine.sendMessage(
        JSON.stringify({
          type: "editable_text",
          message: {
            event: "onChanged",
            target: this.attributes.onChanged,
            data: value,
          },
        })
      );
    }
  }
}
