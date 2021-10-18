const fs = require("fs");
const loopCount = 64;

const template = fs.readFileSync("./base.wxml", { encoding: "utf-8" });
let output = "";
for (let index = 1; index < loopCount + 1; index++) {
  output += template.replace("fn", "f" + index);
}

output += `
<template name="f${loopCount + 1}">
    <renderer id="renderer" root="{{rt.id}}" />
</template>
`;

let code = fs.readFileSync("./miniprogram_dist/renderer.wxml", {
  encoding: "utf-8",
});
code = code.replace("<!-- floop -->", output).replace(/    /g, '');
fs.writeFileSync("./miniprogram_dist/renderer.wxml", code);
