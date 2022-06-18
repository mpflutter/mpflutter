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
      if (prop === "__keys__") {
        let keys: string[] = [];
        if (obj?.b) {
          keys.push(...Object.keys(obj.b));
        }
        if (obj?.c) {
          keys.push(...Object.keys(obj.c));
        }
        if (obj?._nums) {
          keys.push(...Object.keys(obj._nums));
        }
        if (obj?._strings) {
          keys.push(...Object.keys(obj._strings));
        }
        return keys;
      }
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
