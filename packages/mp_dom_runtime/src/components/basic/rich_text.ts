declare var wx: any;

import { MPEnv, PlatformType } from "../../env";
import { ComponentView } from "../component_view";
import { setDOMAttribute, setDOMStyle } from "../dom_utils";
import { cssTextAlign, cssTextStyle } from "../utils";

export class RichText extends ComponentView {
  private measuring = false;
  didSetOnClicked = false;
  canMeasureResultCache = false;
  textCache = "";
  textCacheSize = 0;
  measureId: number | undefined;
  maxWidth: number | string | undefined;
  maxHeight: number | string | undefined;

  elementType() {
    return "div";
  }

  setConstraints(constraints?: any) {
    if (this.measuring) return;
    if (!constraints) return;
    this.constraints = constraints;
    this.updateLayout();
    setDOMStyle(this.htmlElement, { position: "absolute", opacity: "1" });
  }

  setAttributes(attributes: any) {
    super.setAttributes(attributes);
    if (__MP_MINI_PROGRAM__) {
      this.htmlElement.classList.add("mp_text");
    }
    const maxWidth = attributes.maxWidth;
    if (typeof maxWidth === "string") {
      this.maxWidth = parseFloat(maxWidth);
    } else {
      this.maxWidth = undefined;
    }
    const maxHeight = attributes.maxHeight;
    if (typeof maxHeight === "string") {
      this.maxHeight = parseFloat(maxHeight);
    } else {
      this.maxHeight = undefined;
    }
    setDOMStyle(this.htmlElement, {
      overflow: "hidden",
      textOverflow: "ellipsis",
      textAlign: cssTextAlign(attributes.textAlign),
      display: !attributes.maxLines && attributes.textAlign ? "unset" : "-webkit-box",
      fontSize: "11px",
      fontFamily: "sans-serif",
      lineHeight: attributes.height?.toString(),
      overflowWrap: "anywhere",
      wordBreak: "break-all",
      wordWrap: "break-word",
      whiteSpace: "pre-line",
      webkitBoxOrient: "vertical",
      webkitLineClamp: attributes.maxLines ? attributes.maxLines.toString() : "99999",
    });

    this.measureId = attributes.measureId;
  }

  async setSingleTextSpan(children: any) {
    let style: any = {};
    if (children[0].attributes.style) {
      let s = cssTextStyle(children[0].attributes.style);
      if (this.attributes.selectable) {
        delete s.userSelect;
        delete s.WebkitUserSelect;
      }
      for (const key in s) {
        style[key] = s[key];
      }
    }
    if (children[0].attributes.text) {
      const text = children[0].attributes.text;
      (this.htmlElement as HTMLDivElement).innerText = text;
      if (!style.letterSpacing && !style.wordSpacing && !style.height && /[^㐀-𫠚]/g.test(text) === false) {
        this.canMeasureResultCache = true;
        this.textCache = text;
        this.textCacheSize = parseInt(style["fontSize"]);
      }
    }
    if (children[0].attributes.onTap_el && children[0].attributes.onTap_span && !this.didSetOnClicked) {
      this.didSetOnClicked = true;
      this.htmlElement.addEventListener("click", (e) => {
        this.onClick(children[0].attributes.onTap_el, children[0].attributes.onTap_span);
        if (e) e.stopPropagation();
      });
    }
    setDOMStyle(this.htmlElement, style);
  }

  async setChildren(children: any) {
    if (children && children.length === 1 && children[0].name === "text_span" && children[0].attributes?.text) {
      this.setSingleTextSpan(children);
    } else {
      super.setChildren(children);
    }
  }

  onClick(el: string, onTap_span: string) {
    this.engine.sendMessage(
      JSON.stringify({
        type: "rich_text",
        message: {
          event: "onTap",
          target: el,
          subTarget: onTap_span,
        },
      })
    );
  }
}

export class TextSpan extends ComponentView {
  didSetOnClicked = false;

  elementType() {
    return "div";
  }

  setChildren(children: any) {
    if (children instanceof Array && children.length > 0) {
      super.setChildren(children);
    }
  }

  setAttributes(attributes: any) {
    super.setAttributes(attributes);
    let style: any = {
      position: "unset",
      display: "inline",
    };
    if (attributes.style) {
      let s = cssTextStyle(attributes.style);
      if (attributes.selectable) {
        delete s.userSelect;
        delete s.WebkitUserSelect;
      }
      for (const key in s) {
        style[key] = s[key];
      }
    }
    if (attributes.text) {
      (this.htmlElement as HTMLSpanElement).innerText = attributes.text;
      if (__MP_MINI_PROGRAM__) {
        setDOMAttribute(this.htmlElement, "innerText", attributes.text);
      }
    }
    if (attributes.onTap_el && attributes.onTap_span && !this.didSetOnClicked) {
      this.didSetOnClicked = true;
      this.htmlElement.addEventListener("click", (e) => {
        this.onClick();
        if (e) e.stopPropagation();
      });
    }
    setDOMStyle(this.htmlElement, style);
  }

  onClick() {
    if (this.attributes.onTap_el && this.attributes.onTap_span) {
      this.engine.sendMessage(
        JSON.stringify({
          type: "rich_text",
          message: {
            event: "onTap",
            target: this.attributes.onTap_el,
            subTarget: this.attributes.onTap_span,
          },
        })
      );
    }
  }
}

export class WidgetSpan extends ComponentView {
  elementType() {
    return "div";
  }

  setChildren(children: any) {
    super.setChildren(children);
    if (this.subviews[0]) {
      this.subviews[0].additionalConstraints = { position: "relative" };
      setDOMStyle(this.subviews[0].htmlElement, {
        position: "relative",
        display: "inline-flex",
      });
    }
  }

  setAttributes(attributes: any) {
    super.setAttributes(attributes);
    setDOMStyle(this.htmlElement, { display: "contents" });
  }
}
