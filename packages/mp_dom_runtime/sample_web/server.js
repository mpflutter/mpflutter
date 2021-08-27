const http = require("http");
const fs = require("fs");
const path = require("path");

http
  .createServer(function (request, response) {
    const localFilePath = path.join(".", request.url);
    if (fs.existsSync(localFilePath) && fs.lstatSync(localFilePath).isFile()) {
      response.write(fs.readFileSync(localFilePath, { encoding: "utf-8" }));
    } else {
      response.write(fs.readFileSync("index.html", { encoding: "utf-8" }));
    }
    response.end();
  })
  .listen(8080);

console.log("Server running at http://127.0.0.1:8080/");
