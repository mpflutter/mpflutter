const fs = require("fs");

let targets = ["__MP_TARGET_BROWSER__", "__MP_TARGET_WEAPP__", "__MP_TARGET_SWANAPP__"];
let targetFile = {
  __MP_TARGET_BROWSER__: "mpdom.js",
  __MP_TARGET_WEAPP__: "mpdom.miniprogram.js",
  __MP_TARGET_SWANAPP__: "mpdom.miniprogram.js",
};
let currentTarget = process.argv[2];

let code = fs.readFileSync("./dist/" + targetFile[currentTarget], { encoding: "utf8" });
targets.forEach((it) => {
  code = code.replace(RegExp(it, "g"), it === currentTarget ? "true" : "false");
});
fs.writeFileSync("./dist/mpdom.js." + currentTarget, code);
