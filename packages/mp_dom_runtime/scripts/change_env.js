const fs = require("fs");

let targets = [
  "__MP_TARGET_BROWSER__",
  "__MP_TARGET_WEAPP__",
  "__MP_TARGET_SWANAPP__",
  "__MP_TARGET_TT__",
  "__MP_TARGET_CANVAS__",
];
let targetFile = {
  __MP_TARGET_BROWSER__: "mpdom.js",
  __MP_TARGET_WEAPP__: "mpdom.miniprogram.js",
  __MP_TARGET_SWANAPP__: "mpdom.miniprogram.js",
  __MP_TARGET_TT__: "mpdom.miniprogram.js",
  __MP_TARGET_CANVAS__: "mpdom.canvas.js",
};
let currentTarget = process.argv[2];

let code = fs.readFileSync("./dist/" + targetFile[currentTarget], { encoding: "utf8" });
targets.forEach((it) => {
  code = code.replace(RegExp(it, "g"), it === currentTarget ? "true" : "false");
});
let isMiniProgram =
  currentTarget === "__MP_TARGET_SWANAPP__" ||
  currentTarget === "__MP_TARGET_WEAPP__" ||
  currentTarget === "__MP_TARGET_TT__";
if (isMiniProgram) {
  code = code.replace(RegExp("__MP_MINI_PROGRAM__", "g"), "true");
} else {
  code = code.replace(RegExp("__MP_MINI_PROGRAM__", "g"), "false");
}
if (currentTarget === "__MP_TARGET_CANVAS__") {
  code = code.replace(RegExp("__MP_TARGET_CANVAS__", "g"), "true");
}
fs.writeFileSync("./dist/mpdom.js." + currentTarget, code);
