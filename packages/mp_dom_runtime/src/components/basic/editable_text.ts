import { MPEnv, PlatformType } from "../../env";
import { ComponentView } from "../component_view";
import { setDOMAttribute, setDOMStyle } from "../dom_utils";
import { cssColor, cssTextAlign, cssTextStyle } from "../utils";

export class EditableText extends ComponentView {
  contentElement?: HTMLInputElement | HTMLTextAreaElement;
  contentElementType = "";
  didSetListener = false;

  setAttributes(attributes: any) {
    super.setAttributes(attributes);
    const maxLines = attributes.maxLines;

    if (maxLines > 1 && this.contentElementType !== "textarea") {
      this.contentElement?.remove();
      this.contentElement = this.document.createElement("textarea");
      this.didSetListener = false;
      this.contentElementType = "textarea";
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
      this.didSetListener = false;
      this.contentElementType = "input";
      setDOMStyle(this.contentElement, {
        width: "100%",
        height: "100%",
        backgroundColor: "transparent",
        border: "none",
      });
      this.htmlElement.appendChild(this.contentElement);
    }
    if (!this.contentElement) return;
    if (attributes.placeholderStyle) {
      let placeholderStyle = "";
      if (attributes.placeholderStyle.color) {
        placeholderStyle += `color: ${cssColor(attributes.placeholderStyle.color)};`;
      }
      setDOMAttribute(this.contentElement, "placeholder-style", placeholderStyle);
    }
    this.contentElement.onkeyup = (event) => {
      if (event.key === "Enter" || event.keyCode === 13) {
        this._onSubmitted(event.target as HTMLInputElement, (event.target as HTMLInputElement).value);
      }
    };
    if (!this.didSetListener) {
      this.didSetListener = true;
      this.contentElement.addEventListener("submit", (event: any) => {
        this._onSubmitted(event.target, event.detail?.value ?? (event.target as HTMLInputElement).value);
      });
      this.contentElement.addEventListener("confirm", (event: any) => {
        this._onSubmitted(event.target, event.detail?.value ?? (event.target as HTMLInputElement).value);
      });
      this.contentElement.addEventListener("input", (event: any) => {
        this._onChanged(event.target, event.detail?.value ?? (event.target as HTMLInputElement).value);
      });
      this.contentElement.addEventListener("focus", () => {
        this.engine.sendMessage(
          JSON.stringify({
            type: "editable_text",
            message: {
              event: "onFocus",
              target: this.hashCode,
            },
          })
        );
      });
      this.contentElement.addEventListener("blur", () => {
        this.engine.sendMessage(
          JSON.stringify({
            type: "editable_text",
            message: {
              event: "onBlur",
              target: this.hashCode,
            },
          })
        );
      });
    }
    this.contentElement.onchange = (event: any) => {
      this._onChanged(event.target, event.detail?.value ?? (event.target as HTMLInputElement).value);
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
      attributes.obscureText ? "password" : this._keyboardType(attributes.keyboardType)
    );
    const keybordPattern = this._keyboardPattern(attributes.keyboardType);
    if (__MP_TARGET_BROWSER__) {
      setDOMAttribute(this.contentElement, "pattern", keybordPattern);
      if (keybordPattern === "[0-9+.]*") {
        setDOMAttribute(this.contentElement, "inputmode", "decimal");
      }
    }
    if (typeof attributes.value === "string") {
      if (__MP_MINI_PROGRAM__) {
        setDOMAttribute(this.contentElement, "value", attributes.value);
      } else {
        this.contentElement.value = attributes.value;
      }
    }
    if (attributes.autofocus) {
      setDOMAttribute(this.contentElement, "auto-focus", attributes.autofocus);
    }
    if (attributes.autoCorrect) {
      setDOMAttribute(this.contentElement, "auto-correct", attributes.autoCorrect);
    }
    if (attributes.placeholder) {
      setDOMAttribute(this.contentElement, "placeholder", attributes.placeholder);
    }
    if (attributes.maxLength) {
      setDOMAttribute(this.contentElement, "maxlength", attributes.maxLength);
    }
    if (__MP_MINI_PROGRAM__) {
      setDOMAttribute(this.contentElement, "disabled", attributes.readOnly ? "true" : undefined);
    } else {
      setDOMAttribute(this.contentElement, "read-only", attributes.readOnly ? "true" : undefined);
    }
    if (__MP_MINI_PROGRAM__) {
      setDOMAttribute(this.contentElement, "confirm-type", this._textInputAction(attributes.textInputAction));
    }
  }

  setChildren() {}

  _keyboardType(value: string) {
    if (value?.indexOf("TextInputType.number") >= 0) {
      if (__MP_TARGET_WEAPP__) {
        const decimal = value.indexOf("decimal: true") >= 0;
        if (decimal) {
          return "digit";
        }
      }
      return "number";
    }
    if (__MP_TARGET_WEAPP__ && value?.indexOf("TextInputType.idcard") >= 0) {
      return "idcard";
    }
    return "text";
  }

  _keyboardPattern(value: string) {
    if (value?.indexOf("TextInputType.number") >= 0) {
      const signed = value.indexOf("signed: true") >= 0;
      const decimal = value.indexOf("decimal: true") >= 0;
      if (signed && decimal) {
        return "[0-9+-.]*";
      }
      if (signed && !decimal) {
        return "[0-9+-]*";
      }
      if (!signed && !decimal) {
        return "[0-9]*";
      }
      if (!signed && decimal) {
        return "[0-9+.]*";
      }
    }
    return "";
  }

  _textInputAction(value: string) {
    return value.replace("TextInputAction.", "");
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
