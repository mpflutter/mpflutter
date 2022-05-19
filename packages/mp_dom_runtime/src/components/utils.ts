export const cssColor = (value: string) => {
  const intValue = parseInt(value);

  let r = ((intValue >> 16) & 0xff).toString(16);
  if (r.length < 2) {
    r = "0" + r;
  }
  let g = ((intValue >> 8) & 0xff).toString(16);
  if (g.length < 2) {
    g = "0" + g;
  }
  let b = ((intValue >> 0) & 0xff).toString(16);
  if (b.length < 2) {
    b = "0" + b;
  }
  let a = ((intValue >> 24) & 0xff).toString(16);
  if (a === "ff") {
    return `#${r}${g}${b}`;
  }
  if (a.length < 2) {
    a = "0" + a;
  }
  return `rgba(${(intValue >> 16) & 0xff},${(intValue >> 8) & 0xff},${
    (intValue >> 0) & 0xff
  },${((intValue >> 24) & 0xff) / 255.0})`;
};

export const cssColorHex = (value: string) => {
  const intValue = parseInt(value);

  let r = ((intValue >> 16) & 0xff).toString(16);
  if (r.length < 2) {
    r = "0" + r;
  }
  let g = ((intValue >> 8) & 0xff).toString(16);
  if (g.length < 2) {
    g = "0" + g;
  }
  let b = ((intValue >> 0) & 0xff).toString(16);
  if (b.length < 2) {
    b = "0" + b;
  }
  return `#${r}${g}${b}`;
};

export const cssBorderRadius = (value: string): any => {
  if (value.indexOf("BorderRadius.circular(") === 0) {
    const trimedValue = value
      .replace("BorderRadius.circular(", "")
      .replace(")", "");
    return { borderRadius: trimedValue + "px" };
  } else if (value.indexOf("BorderRadius.all(") === 0) {
    const trimedValue = value.replace("BorderRadius.all(", "").replace(")", "");
    return { borderRadius: trimedValue + "px" };
  } else if (value.indexOf("BorderRadius.only(") === 0) {
    const trimedValue = value
      .replace("BorderRadius.only(", "")
      .replace(/\)/gi, "")
      .replace(/Radius.circular\(/gi, "");
    const topLeft = trimedValue.match(/topLeft: ([0-9|.]+)/)?.[1] ?? 0;
    const topRight = trimedValue.match(/topRight: ([0-9|.]+)/)?.[1] ?? 0;
    const bottomLeft = trimedValue.match(/bottomLeft: ([0-9|.]+)/)?.[1] ?? 0;
    const bottomRight = trimedValue.match(/bottomRight: ([0-9|.]+)/)?.[1] ?? 0;
    return {
      borderTopLeftRadius: `${topLeft}px`,
      borderTopRightRadius: `${topRight}px`,
      borderBottomLeftRadius: `${bottomLeft}px`,
      borderBottomRightRadius: `${bottomRight}px`,
    };
  } else {
    return { borderRadius: "0px" };
  }
};

export const cssGradient = (value: any) => {
  if (!value) return "";
  if (value.classname === "LinearGradient") {
    let end = (() => {
      switch (value.end) {
        case "centerRight":
          return "to right";
        case "centerLeft":
          return "to left";
        case "topRight":
          return "to top right";
        case "bottomRight":
          return "to bottom right";
        case "topLeft":
          return "to top left";
        case "bottomLeft":
          return "to bottom left";
        case "topCenter":
          return "to top";
        case "bottomCenter":
          return "to bottom";
        default:
          break;
      }
    })();
    let segments: string[] = [];
    if (value.stops && value.stops.length) {
      segments = value.colors.map((it: string, idx: number) => {
        if (value.stops[idx] !== undefined) {
          return `${cssColor(it)} ${(value.stops[idx] * 100).toFixed(0)}%`;
        } else {
          return cssColor(it);
        }
      });
    } else {
      segments = value.colors.map((it: string) => cssColor(it));
    }
    return `linear-gradient(${end}, ${segments.join(", ")})`;
  }
  return ``;
};

export const cssOffset = (
  value: string
): { dx: string; dy: string } | undefined => {
  if (value.indexOf("Offset(") === 0) {
    const trimedValue = value.replace("Offset(", "").replace(")", "");
    const values = trimedValue.split(",").map((it) => it.trim());
    return { dx: values[0], dy: values[1] };
  } else {
    return undefined;
  }
};

export const cssBorder = (value: any) => {
  let output: any = {};
  if (value[`topStyle`] !== "BorderStyle.none") {
    output.borderTopWidth =
      value.topWidth === 0.0
        ? `${(1.0 / window.devicePixelRatio).toFixed(2)}px`
        : value.topWidth + "px";
    output.borderTopColor = cssColor(value.topColor);
    output.borderTopStyle = "solid";
  }
  if (value[`leftStyle`] !== "BorderStyle.none") {
    output.borderLeftWidth =
      value.leftWidth === 0.0
        ? `${(1.0 / window.devicePixelRatio).toFixed(2)}px`
        : value.leftWidth + "px";
    output.borderLeftColor = cssColor(value.leftColor);
    output.borderLeftStyle = "solid";
  }
  if (value[`bottomStyle`] !== "BorderStyle.none") {
    output.borderBottomWidth =
      value.bottomWidth === 0.0
        ? `${(1.0 / window.devicePixelRatio).toFixed(2)}px`
        : value.bottomWidth + "px";
    output.borderBottomColor = cssColor(value.bottomColor);
    output.borderBottomStyle = "solid";
  }
  if (value[`rightStyle`] !== "BorderStyle.none") {
    output.borderRightWidth =
      value.rightWidth === 0.0
        ? `${(1.0 / window.devicePixelRatio).toFixed(2)}px`
        : value.rightWidth + "px";
    output.borderRightColor = cssColor(value.rightColor);
    output.borderRightStyle = "solid";
  }
  return output;
};

export const cssTextAlign = (value: any) => {
  let v = value?.replace("TextAlign.", "");
  if (v === 'start') {
    return 'left';
  }
  else if (v === 'end') {
    return 'right';
  }
  else {
    return v;
  }
};

export function getFontWeightStyle(data: any) {
  if (data.fontWeight) {
    return data.fontWeight.replace("FontWeight.w", "");
  }
  return undefined;
}

export function getFontStyleStyle(data: any) {
  if (data.fontStyle === "FontStyle.italic") {
    return "italic";
  }
  return undefined;
}

export function getBaselineStyle(data: any) {
  if (data.textBaseline === "TextBaseline.alphabetic") {
    return "alphabetic";
  } else if (data.textBaseline === "TextBaseline.ideographic") {
    return "ideographic";
  } else if (data.textBaseline === "TextBaseline.top") {
    return "top";
  } else if (data.textBaseline === "TextBaseline.middle") {
    return "middle";
  } else if (data.textBaseline === "TextBaseline.bottom") {
    return "bottom";
  }
  return undefined;
}

export function cssTextStyle(data: any): any {
  let style: any = {
    userSelect: "none",
    WebkitUserSelect: "none",
  };

  if (data != null) {
    if (data.fontFamily) {
      style.fontFamily = data.fontFamily;
    }
    if (data.fontSize != null) {
      style.fontSize = `${(data.fontSize ?? 14).toString()}px`;
    }
    if (data.color != null) {
      style.color = cssColor(data.color);
    }
    if (data.fontWeight) {
      style.fontWeight = getFontWeightStyle(data);
    }
    if (data.fontStyle) {
      style.fontStyle = getFontStyleStyle(data);
    }
    if (data.letterSpacing) {
      style.letterSpacing = data.letterSpacing;
    }
    if (data.wordSpacing) {
      style.wordSpacing = data.wordSpacing;
    }
    if (data.textBaseline) {
      style.alignmentBaseline = getBaselineStyle(data);
    }
    if (data.height) {
      style.lineHeight = data.height;
    }
    if (data.backgroundColor != null) {
      style.backgroundColor = cssColor(data.backgroundColor);
    }
    if (data.decoration) {
      if (data.decoration === "TextDecoration.lineThrough") {
        style.textDecoration = "line-through";
      } else if (data.decoration === "TextDecoration.underline") {
        style.textDecoration = "underline";
      }
    }
  }
  return style;
}

export const cssPadding = (value: string) => {
  if (!value) return {};
  if (value.indexOf("EdgeInsets.zero") === 0) {
    return {};
  } else if (value.indexOf("EdgeInsets.all(") === 0) {
    const trimedValue = value.replace("EdgeInsets.all(", "").replace(")", "");
    return {
      paddingLeft: trimedValue + "px",
      paddingTop: trimedValue + "px",
      paddingRight: trimedValue + "px",
      paddingBottom: trimedValue + "px",
    };
  } else if (value.indexOf("EdgeInsets(") === 0) {
    const trimedValue = value.replace("EdgeInsets(", "").replace(")", "");
    const values = trimedValue.split(",").map((it) => it.trim());
    return {
      paddingLeft: values[0] + "px",
      paddingTop: values[1] + "px",
      paddingRight: values[2] + "px",
      paddingBottom: values[3] + "px",
    };
  } else {
    return {};
  }
};

export const cssSizeFromMPElement = (
  element: any
): { width: number; height: number } => {
  if (!element) return { width: 0, height: 0 };
  let width = 0;
  let height = 0;
  if (
    element.constraints &&
    typeof element.constraints.w === "number" &&
    typeof element.constraints.h === "number" &&
    element.constraints.w > 0 &&
    element.constraints.h > 0
  ) {
    width = element.constraints.w;
    height = element.constraints.h;
  } else if (
    element.children instanceof Array &&
    element.children.length === 1
  ) {
    return cssSizeFromMPElement(element.children[0]);
  }
  return { width, height };
};
