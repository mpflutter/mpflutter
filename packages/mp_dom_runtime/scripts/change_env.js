const fs = require("fs");

let targets = ["__MP_TARGET_BROWSER__", "__MP_TARGET_WEAPP__", "__MP_TARGET_SWANAPP__", "__MP_TARGET_TT__"];
let targetFile = {
  __MP_TARGET_BROWSER__: "mpdom.js",
  __MP_TARGET_WEAPP__: "mpdom.miniprogram.js",
  __MP_TARGET_SWANAPP__: "mpdom.miniprogram.js",
  __MP_TARGET_TT__: "mpdom.miniprogram.js",
};
let currentTarget = process.argv[2];

let code = fs.readFileSync("./dist/" + targetFile[currentTarget], { encoding: "utf8" });
targets.forEach((it) => {
  let isMiniProgram = it === '__MP_TARGET_SWANAPP__' || it === '__MP_TARGET_WEAPP__' || it === '__MP_TARGET_TT__';
  code = code.replace(RegExp(it, "g"), it === currentTarget ? "true" : "false");
  if (isMiniProgram) {
    code = code.replace(RegExp('__MP_MINI_PROGRAM__', "g"), "true");
  }
  else {
    code = code.replace(RegExp('__MP_MINI_PROGRAM__', "g"), "false");
  }
});
fs.writeFileSync("./dist/mpdom.js." + currentTarget, code);
