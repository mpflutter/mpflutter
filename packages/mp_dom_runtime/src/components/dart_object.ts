declare var Proxy: any;

export const wrapDartObject = (dartObject: any): any => {
  if (
    dartObject === undefined ||
    dartObject === null ||
    typeof dartObject === "string" ||
    typeof dartObject === "number" ||
    typeof dartObject === "boolean"
  ) {
    return dartObject;
  } else if (dartObject instanceof Array) {
    return dartObject.map((it) => wrapDartObject(it));
  }
  if (dartObject.o) {
    dartObject = dartObject.o;
  }
  return new Proxy(dartObject, {
    get: function (obj: any, prop: any) {
      let finalValue =
        obj?.b?.[prop]?.b ??
        obj?.c?.[prop]?.b ??
        obj?._nums?.[prop]?.hashMapCellValue ??
        obj?._strings?.[prop]?.hashMapCellValue ??
        obj[prop];
      return wrapDartObject(finalValue);
    },
  });
};
