declare var Proxy: any;

export const wrapDartObject = (dartObject: any) => {
  if (dartObject.o) {
    dartObject = dartObject.o;
  }
  return new Proxy(dartObject, {
    get: function (obj: any, prop: any) {
      let finalValue = obj?.b?.[prop]?.b ?? obj?.c?.[prop]?.b;
      if (
        finalValue &&
        finalValue !== null &&
        !(finalValue instanceof Array) &&
        typeof finalValue === "object"
      ) {
        return wrapDartObject(finalValue);
      }
      return finalValue;
    },
  });
};
