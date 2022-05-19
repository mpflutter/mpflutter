const YAML = require("yaml");
const { execSync } = require("child_process");
const COS = require("cos-nodejs-sdk-v5");
const { env } = require("process");
const {
  createReadStream,
  readFileSync,
  createWriteStream,
  existsSync,
  writeFileSync,
} = require("fs");
const cosInstance = new COS({
  SecretId: env["COS_SECRET_ID"],
  SecretKey: env["COS_SECRET_KEY"],
  UseAccelerate: true,
});
const cosBucket = "mpflutter-dist-1253771526";
const cosRegion = "ap-guangzhou";

const currentVersion = env['GITHUB_REF_NAME'];

class PodPackageDeployer {
  constructor(name) {
    this.name = name;
  }

  async deploy() {
    console.log("[start]deploying pod" + this.name, new Date().toString());
    this.replaceVersion();
    this.makeArchive();
    const archiveUrl = await this.uploadArchive();
    console.log("[end]deploying package" + this.name, new Date().toString());
    console.log(archiveUrl);
  }

  replaceVersion() {
    let originPodspec = readFileSync(`../packages/mp_ios_runtime/MPIOSRuntime.podspec`, {encoding: "utf-8"});
    originPodspec = originPodspec.replace(/spec.version      = ".*?"/, `spec.version      = "${currentVersion}"`);
    writeFileSync(`../packages/mp_ios_runtime/MPIOSRuntime.podspec`, originPodspec);
  }

  makeArchive() {
    execSync(`tar -cf ${currentVersion}.tar *`, {
      cwd: `../packages/mp_ios_runtime`,
    });
    execSync(`mv ${currentVersion}.tar /tmp/${currentVersion}.tar`, {
      cwd: `../packages/mp_ios_runtime`,
    });
  }

  uploadArchive() {
    return new Promise((res, rej) => {
      cosInstance.putObject(
        {
          Bucket: cosBucket,
          Region: cosRegion,
          Key: `/ios/versions/${currentVersion}.tar`,
          StorageClass: "STANDARD",
          Body: createReadStream(`/tmp/${currentVersion}.tar`),
        },
        (err, data) => {
          if (!err) {
            res(
              `https://dist.mpflutter.com/ios/versions/${currentVersion}.tar`
            );
          } else {
            rej(err)
          }
        }
      );
    });
  }

}

new PodPackageDeployer().deploy();